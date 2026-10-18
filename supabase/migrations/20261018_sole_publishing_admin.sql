-- ============================================================================
-- Migration: Sole Publishing Administrator and Property Review Lifecycle Hardening (v8)
-- Target: Yemen Real Estate Portal (بوابة اليمن العقارية)
-- Author: Mohammed Al-Saqqaf (Sole Publishing Administrator)
-- Date: 2026-10-18
--
-- STRICT OPERATIONAL BOUNDARY:
-- This migration hardens database security, triggers, and RLS policies locally.
-- It must NOT be applied to production without explicit confirmation.
--
-- V8 ENHANCEMENTS:
-- 1. Fail-closed administrator verification (aborts migration on mismatch or unconfirmed email).
-- 2. Private, zero-privilege internal ticket queue for media resets (no reliance on GUC or trigger depth).
-- 3. Strict barrier preventing normal users from mutating reviewed_by, reviewed_at, or rejection_reason.
-- 4. Dynamic comprehensive cleanup of all legacy policies on affected tables.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. Ensure Columns, Types, and Constraints Exist Safely
-- ----------------------------------------------------------------------------

-- Ensure profiles table has email column for identity verification & client model compatibility
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email TEXT;

-- Add review audit columns if not present
ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS images_updated_at TIMESTAMPTZ DEFAULT pg_catalog.now();

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE;

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0;

-- Ensure status constraint is clean and valid
ALTER TABLE public.properties
DROP CONSTRAINT IF EXISTS chk_properties_status;

ALTER TABLE public.properties
ADD CONSTRAINT chk_properties_status
CHECK (status IN ('pending', 'published', 'rejected', 'archived'));

-- Optimization indexes
CREATE INDEX IF NOT EXISTS idx_properties_sole_admin_lookup
ON public.properties(status, owner_id);

CREATE INDEX IF NOT EXISTS idx_properties_images_updated_at
ON public.properties(images_updated_at);

-- ----------------------------------------------------------------------------
-- 2. Internal Media Reset Queue (Zero-Client Access)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public._property_media_resets (
    property_id UUID PRIMARY KEY REFERENCES public.properties(id) ON DELETE CASCADE,
    token UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.clock_timestamp()
);

-- Enable RLS and revoke all permissions from public, anon, and authenticated
ALTER TABLE public._property_media_resets ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public._property_media_resets FROM PUBLIC;
REVOKE ALL ON TABLE public._property_media_resets FROM anon;
REVOKE ALL ON TABLE public._property_media_resets FROM authenticated;

-- ----------------------------------------------------------------------------
-- 3. Validate Administrator Identity & Email Confirmation (Fail-Closed)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_target_id CONSTANT UUID := 'daa0d684-f82b-4878-9d86-ce2810be9786'::UUID;
    v_target_email CONSTANT TEXT := 'mohammed.f.saqqaf@gmail.com';
    v_auth_confirmed BOOLEAN := FALSE;
    v_profile_exists BOOLEAN := FALSE;
    v_rows_affected INT := 0;
BEGIN
    -- Check if auth.users is accessible in current execution environment
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'auth' AND table_name = 'users'
    ) THEN
        SELECT (email_confirmed_at IS NOT NULL) INTO v_auth_confirmed
        FROM auth.users
        WHERE id = v_target_id
          AND lower(email) = lower(v_target_email);

        IF v_auth_confirmed IS NULL THEN
            RAISE EXCEPTION 'MIGRATION ABORTED: Sole publishing admin (%) does not exist in auth.users with UUID %.', v_target_email, v_target_id;
        END IF;

        IF NOT v_auth_confirmed THEN
            RAISE EXCEPTION 'MIGRATION ABORTED: Sole publishing admin email (%) is not confirmed.', v_target_email;
        END IF;
    END IF;

    -- Verify profile exists in public.profiles
    SELECT EXISTS (
        SELECT 1 FROM public.profiles WHERE id = v_target_id
    ) INTO v_profile_exists;

    IF NOT v_profile_exists THEN
        RAISE EXCEPTION 'MIGRATION ABORTED: Profile for administrator (%) does not exist in public.profiles.', v_target_id;
    END IF;

    -- Update administrative role and ensure email is set without touching personal phone or display name
    UPDATE public.profiles
    SET 
        role = 'super_admin',
        is_verified = TRUE,
        email = v_target_email,
        updated_at = pg_catalog.now()
    WHERE id = v_target_id
      AND (email IS NULL OR lower(email) = lower(v_target_email));

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected <> 1 THEN
        RAISE EXCEPTION 'MIGRATION ABORTED: Expected exactly 1 admin profile row updated, affected %', v_rows_affected;
    END IF;

    -- Synchronize existing profile emails from auth.users if available
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'auth' AND table_name = 'users'
    ) THEN
        UPDATE public.profiles p
        SET email = u.email
        FROM auth.users u
        WHERE p.id = u.id AND (p.email IS NULL OR p.email = '');
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 4. Sole Publishing Administrator Verification Function
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_sole_publishing_admin(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
    v_target_id CONSTANT UUID := 'daa0d684-f82b-4878-9d86-ce2810be9786'::UUID;
    v_target_email CONSTANT TEXT := 'mohammed.f.saqqaf@gmail.com';
    v_is_authorized BOOLEAN := FALSE;
    v_current_role TEXT := NULLIF(pg_catalog.current_setting('role', true), '');
BEGIN
    IF check_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Prevent arbitrary user probing by non-service callers
    IF v_current_role NOT IN ('service_role', 'postgres', 'supabase_admin') THEN
        IF auth.uid() IS NULL OR auth.uid() <> check_user_id THEN
            RETURN FALSE;
        END IF;
    END IF;

    IF check_user_id <> v_target_id THEN
        RETURN FALSE;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = v_target_id
          AND lower(email) = lower(v_target_email)
          AND role = 'super_admin'
          AND is_verified = TRUE
    ) INTO v_is_authorized;

    RETURN v_is_authorized;
END;
$$;

REVOKE ALL ON FUNCTION public.is_sole_publishing_admin(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_sole_publishing_admin(UUID) FROM anon;
GRANT EXECUTE ON FUNCTION public.is_sole_publishing_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_sole_publishing_admin(UUID) TO service_role;

-- ----------------------------------------------------------------------------
-- 5. Property Review & Publishing Lifecycle Trigger
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_property_publishing_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
    v_caller_is_admin BOOLEAN := FALSE;
    v_caller_id UUID := auth.uid();
    v_media_ticket_consumed BOOLEAN := FALSE;
    v_content_changed BOOLEAN := FALSE;
BEGIN
    IF v_caller_id IS NOT NULL THEN
        v_caller_is_admin := public.is_sole_publishing_admin(v_caller_id);
    END IF;

    -- Handle INSERT operations
    IF TG_OP = 'INSERT' THEN
        IF NOT v_caller_is_admin THEN
            NEW.status := 'pending';
            NEW.reviewed_by := NULL;
            NEW.reviewed_at := NULL;
            NEW.rejection_reason := NULL;
            NEW.is_featured := FALSE;
            NEW.views_count := 0;
            NEW.created_at := pg_catalog.now();
            NEW.images_updated_at := pg_catalog.now();
            IF v_caller_id IS NOT NULL THEN
                NEW.owner_id := v_caller_id;
            END IF;
        ELSE
            IF NEW.status IN ('published', 'rejected') THEN
                NEW.reviewed_by := v_caller_id;
                NEW.reviewed_at := pg_catalog.now();
            ELSE
                NEW.reviewed_by := NULL;
                NEW.reviewed_at := NULL;
            END IF;
        END IF;
        RETURN NEW;
    END IF;

    -- Handle UPDATE operations
    IF TG_OP = 'UPDATE' THEN
        -- Ownership & creation timestamp cannot be altered
        IF NEW.owner_id IS DISTINCT FROM OLD.owner_id THEN
            RAISE EXCEPTION 'Property ownership cannot be transferred.';
        END IF;

        IF NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            RAISE EXCEPTION 'Property creation timestamp cannot be altered.';
        END IF;

        -- Non-admin restrictions
        IF NOT v_caller_is_admin THEN
            -- 1. Direct tampering with review metadata (even setting to NULL) is forbidden
            IF (NEW.reviewed_by IS DISTINCT FROM OLD.reviewed_by) OR
               (NEW.reviewed_at IS DISTINCT FROM OLD.reviewed_at) OR
               (NEW.rejection_reason IS DISTINCT FROM OLD.rejection_reason) THEN
                RAISE EXCEPTION 'Direct modification of review metadata is strictly forbidden.';
            END IF;

            -- 2. Featured status and metrics are protected
            IF NEW.is_featured IS DISTINCT FROM OLD.is_featured THEN
                RAISE EXCEPTION 'Only the publishing administrator can alter featured status.';
            END IF;

            IF NEW.views_count IS DISTINCT FROM OLD.views_count AND pg_catalog.pg_trigger_depth() = 1 THEN
                RAISE EXCEPTION 'Direct modification of views count is forbidden.';
            END IF;

            -- 3. Check for substantive content changes
            IF (NEW.title IS DISTINCT FROM OLD.title) OR
               (NEW.description IS DISTINCT FROM OLD.description) OR
               (NEW.price IS DISTINCT FROM OLD.price) OR
               (NEW.city IS DISTINCT FROM OLD.city) OR
               (NEW.district IS DISTINCT FROM OLD.district) OR
               (NEW.area_sqm IS DISTINCT FROM OLD.area_sqm) THEN
                v_content_changed := TRUE;
            END IF;

            -- 4. Check for and atomically consume authorized media reset ticket
            DELETE FROM public._property_media_resets
            WHERE property_id = NEW.id
              AND created_at >= pg_catalog.clock_timestamp() - INTERVAL '15 seconds'
            RETURNING TRUE INTO v_media_ticket_consumed;

            v_media_ticket_consumed := COALESCE(v_media_ticket_consumed, FALSE);

            -- 5. Published property transitions
            IF OLD.status = 'published' THEN
                IF v_media_ticket_consumed OR v_content_changed THEN
                    NEW.status := 'pending';
                    NEW.reviewed_by := NULL;
                    NEW.reviewed_at := NULL;
                    NEW.rejection_reason := NULL;
                ELSE
                    IF NEW.status IS DISTINCT FROM OLD.status THEN
                        RAISE EXCEPTION 'Published properties cannot be manually reverted or altered without substantive content edits or authorized media updates.';
                    END IF;
                END IF;

            -- 6. Pending or Rejected properties
            ELSIF OLD.status IN ('pending', 'rejected') THEN
                IF NEW.status = 'published' THEN
                    RAISE EXCEPTION 'Only the sole administrator can approve and publish properties.';
                END IF;
                IF NEW.status = 'rejected' AND OLD.status <> 'rejected' THEN
                    RAISE EXCEPTION 'Only the sole administrator can reject properties.';
                END IF;
                -- If resubmitting from rejected to pending via content update or state change
                IF OLD.status = 'rejected' AND NEW.status = 'pending' THEN
                    NEW.reviewed_by := NULL;
                    NEW.reviewed_at := NULL;
                    NEW.rejection_reason := NULL;
                END IF;
            END IF;

        ELSE
            -- Sole Admin review actions
            IF NEW.status = 'published' AND OLD.status <> 'published' THEN
                NEW.reviewed_by := v_caller_id;
                NEW.reviewed_at := pg_catalog.now();
                NEW.rejection_reason := NULL;
            ELSIF NEW.status = 'rejected' AND OLD.status <> 'rejected' THEN
                NEW.reviewed_by := v_caller_id;
                NEW.reviewed_at := pg_catalog.now();
            ELSIF NEW.status = 'pending' AND OLD.status <> 'pending' THEN
                NEW.reviewed_by := NULL;
                NEW.reviewed_at := NULL;
                NEW.rejection_reason := NULL;
            END IF;
        END IF;

        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.enforce_property_publishing_rules() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enforce_property_publishing_rules() FROM anon;
REVOKE ALL ON FUNCTION public.enforce_property_publishing_rules() FROM authenticated;
REVOKE ALL ON FUNCTION public.enforce_property_publishing_rules() FROM service_role;

DROP TRIGGER IF EXISTS trg_enforce_property_publishing_rules ON public.properties;
CREATE TRIGGER trg_enforce_property_publishing_rules
    BEFORE INSERT OR UPDATE ON public.properties
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_property_publishing_rules();

-- ----------------------------------------------------------------------------
-- 6. Media Change Cascade Handler (Issues Secure Reset Tickets)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_property_images_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
    v_old_prop_status TEXT;
    v_new_prop_status TEXT;
BEGIN
    -- Moving image across properties (UPDATE with property_id change)
    IF TG_OP = 'UPDATE' THEN
        IF OLD.property_id IS DISTINCT FROM NEW.property_id THEN
            -- Check OLD property
            SELECT status INTO v_old_prop_status FROM public.properties WHERE id = OLD.property_id;
            IF v_old_prop_status = 'published' THEN
                INSERT INTO public._property_media_resets (property_id, token, created_at)
                VALUES (OLD.property_id, gen_random_uuid(), pg_catalog.clock_timestamp())
                ON CONFLICT (property_id) DO UPDATE SET token = gen_random_uuid(), created_at = pg_catalog.clock_timestamp();

                UPDATE public.properties
                SET images_updated_at = pg_catalog.now()
                WHERE id = OLD.property_id;
            END IF;

            -- Check NEW property
            SELECT status INTO v_new_prop_status FROM public.properties WHERE id = NEW.property_id;
            IF v_new_prop_status = 'published' THEN
                INSERT INTO public._property_media_resets (property_id, token, created_at)
                VALUES (NEW.property_id, gen_random_uuid(), pg_catalog.clock_timestamp())
                ON CONFLICT (property_id) DO UPDATE SET token = gen_random_uuid(), created_at = pg_catalog.clock_timestamp();

                UPDATE public.properties
                SET images_updated_at = pg_catalog.now()
                WHERE id = NEW.property_id;
            END IF;
            RETURN NEW;
        END IF;
    END IF;

    -- INSERT or same-property UPDATE
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        SELECT status INTO v_new_prop_status FROM public.properties WHERE id = NEW.property_id;
        IF v_new_prop_status = 'published' THEN
            INSERT INTO public._property_media_resets (property_id, token, created_at)
            VALUES (NEW.property_id, gen_random_uuid(), pg_catalog.clock_timestamp())
            ON CONFLICT (property_id) DO UPDATE SET token = gen_random_uuid(), created_at = pg_catalog.clock_timestamp();

            UPDATE public.properties
            SET images_updated_at = pg_catalog.now()
            WHERE id = NEW.property_id;
        END IF;
        RETURN NEW;
    END IF;

    -- DELETE
    IF TG_OP = 'DELETE' THEN
        SELECT status INTO v_old_prop_status FROM public.properties WHERE id = OLD.property_id;
        IF v_old_prop_status = 'published' THEN
            INSERT INTO public._property_media_resets (property_id, token, created_at)
            VALUES (OLD.property_id, gen_random_uuid(), pg_catalog.clock_timestamp())
            ON CONFLICT (property_id) DO UPDATE SET token = gen_random_uuid(), created_at = pg_catalog.clock_timestamp();

            UPDATE public.properties
            SET images_updated_at = pg_catalog.now()
            WHERE id = OLD.property_id;
        END IF;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_property_images_change() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_property_images_change() FROM anon;
REVOKE ALL ON FUNCTION public.handle_property_images_change() FROM authenticated;
REVOKE ALL ON FUNCTION public.handle_property_images_change() FROM service_role;

DROP TRIGGER IF EXISTS trg_handle_property_images_change ON public.property_images;
CREATE TRIGGER trg_handle_property_images_change
    AFTER INSERT OR UPDATE OR DELETE ON public.property_images
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_property_images_change();

-- ----------------------------------------------------------------------------
-- 7. Profile Security Hardening Trigger
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_profile_security_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
    v_caller_is_admin BOOLEAN := FALSE;
    v_caller_id UUID := auth.uid();
BEGIN
    IF v_caller_id IS NOT NULL THEN
        v_caller_is_admin := public.is_sole_publishing_admin(v_caller_id);
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NOT v_caller_is_admin THEN
            IF NEW.role IS DISTINCT FROM OLD.role THEN
                RAISE EXCEPTION 'Privilege escalation forbidden: role cannot be modified by user.';
            END IF;
            IF NEW.is_verified IS DISTINCT FROM OLD.is_verified THEN
                RAISE EXCEPTION 'Self-verification forbidden: is_verified cannot be modified by user.';
            END IF;
            IF NEW.id IS DISTINCT FROM OLD.id THEN
                RAISE EXCEPTION 'User profile ID cannot be altered.';
            END IF;
        END IF;
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NOT v_caller_is_admin THEN
            IF NEW.role NOT IN ('user', 'client') THEN
                NEW.role := 'user';
            END IF;
            NEW.is_verified := FALSE;
        END IF;
        RETURN NEW;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.enforce_profile_security_rules() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enforce_profile_security_rules() FROM anon;
REVOKE ALL ON FUNCTION public.enforce_profile_security_rules() FROM authenticated;
REVOKE ALL ON FUNCTION public.enforce_profile_security_rules() FROM service_role;

DROP TRIGGER IF EXISTS trg_enforce_profile_security_rules ON public.profiles;
CREATE TRIGGER trg_enforce_profile_security_rules
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_profile_security_rules();

-- ----------------------------------------------------------------------------
-- 8. Comprehensive Dynamic Drop of All Legacy Policies
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename IN ('properties', 'property_images', 'profiles')
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 9. Recreation of Clean, Strictly Hardened Policies
-- ----------------------------------------------------------------------------

-- A. Table: public.properties
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "properties_select_policy"
ON public.properties FOR SELECT
USING (
    status = 'published'
    OR (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_sole_publishing_admin(auth.uid())
);

CREATE POLICY "properties_insert_policy"
ON public.properties FOR INSERT
WITH CHECK (
    auth.uid() IS NOT NULL AND owner_id = auth.uid()
);

CREATE POLICY "properties_update_policy"
ON public.properties FOR UPDATE
USING (
    (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_sole_publishing_admin(auth.uid())
)
WITH CHECK (
    (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_sole_publishing_admin(auth.uid())
);

CREATE POLICY "properties_delete_policy"
ON public.properties FOR DELETE
USING (
    (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_sole_publishing_admin(auth.uid())
);

-- B. Table: public.property_images
ALTER TABLE public.property_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "property_images_select_policy"
ON public.property_images FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_images.property_id
          AND (
              p.status = 'published'
              OR (auth.uid() IS NOT NULL AND p.owner_id = auth.uid())
              OR public.is_sole_publishing_admin(auth.uid())
          )
    )
);

CREATE POLICY "property_images_insert_policy"
ON public.property_images FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_images.property_id
          AND (
              (auth.uid() IS NOT NULL AND p.owner_id = auth.uid())
              OR public.is_sole_publishing_admin(auth.uid())
          )
    )
);

CREATE POLICY "property_images_update_policy"
ON public.property_images FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_images.property_id
          AND (
              (auth.uid() IS NOT NULL AND p.owner_id = auth.uid())
              OR public.is_sole_publishing_admin(auth.uid())
          )
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_images.property_id
          AND (
              (auth.uid() IS NOT NULL AND p.owner_id = auth.uid())
              OR public.is_sole_publishing_admin(auth.uid())
          )
    )
);

CREATE POLICY "property_images_delete_policy"
ON public.property_images FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_images.property_id
          AND (
              (auth.uid() IS NOT NULL AND p.owner_id = auth.uid())
              OR public.is_sole_publishing_admin(auth.uid())
          )
    )
);

-- C. Table: public.profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Phase 1 Compatibility Policy (Essential for Flutter Property Listing & Contact Card)
CREATE POLICY "profiles_select_policy"
ON public.profiles FOR SELECT
USING (true);

CREATE POLICY "profiles_insert_self"
ON public.profiles FOR INSERT
WITH CHECK (
    auth.uid() IS NOT NULL AND auth.uid() = id
);

CREATE POLICY "profiles_update_self"
ON public.profiles FOR UPDATE
USING (
    (auth.uid() IS NOT NULL AND auth.uid() = id)
    OR public.is_sole_publishing_admin(auth.uid())
)
WITH CHECK (
    (auth.uid() IS NOT NULL AND auth.uid() = id)
    OR public.is_sole_publishing_admin(auth.uid())
);

COMMIT;
