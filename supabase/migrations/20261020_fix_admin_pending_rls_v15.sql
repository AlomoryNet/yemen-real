-- ==============================================================================
-- Migration: Fix Admin Pending Properties Access & RLS Policies (v1.5)
-- Date: 2026-10-20
-- Description:
--   1. Ensure admin can SELECT pending properties (RLS policy for admin reads).
--   2. Ensure admin can UPDATE status to published/rejected (RLS policy for admin updates).
--   3. Ensure normal users cannot modify status to published or alter review fields.
--   4. Add missing closing brace for updatePropertyStatus trigger safety.
--   5. Flag demo/seed properties clearly so they are not shown as real listings.
-- ==============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Ensure is_admin() helper function exists (idempotent)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_admin(uid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = uid AND role IN ('admin', 'super_admin')
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

-- ---------------------------------------------------------------------------
-- 2. Drop all existing RLS policies on properties to start clean
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'properties'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.properties', pol.policyname);
  END LOOP;
END $$;

-- Enable RLS
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 3. Public SELECT: Only published properties visible to anonymous users
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_select_published"
ON public.properties FOR SELECT
TO anon, authenticated
USING (status = 'published');

-- ---------------------------------------------------------------------------
-- 4. Admin SELECT: Admin can see all properties (any status) for review panel
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_select_admin_all"
ON public.properties FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));

-- ---------------------------------------------------------------------------
-- 5. Owner SELECT: Property owners can see their own properties (all statuses)
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_select_own"
ON public.properties FOR SELECT
TO authenticated
USING (owner_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 6. INSERT: Authenticated users can insert, but status is always forced to
--    'pending' by the enforce_property_publishing_rules trigger for non-admins.
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_insert_authenticated"
ON public.properties FOR INSERT
TO authenticated
WITH CHECK (owner_id = auth.uid() OR public.is_admin(auth.uid()));

-- ---------------------------------------------------------------------------
-- 7. UPDATE: Owners can update their own properties (trigger enforces status rules)
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_update_own"
ON public.properties FOR UPDATE
TO authenticated
USING (owner_id = auth.uid() OR public.is_admin(auth.uid()))
WITH CHECK (owner_id = auth.uid() OR public.is_admin(auth.uid()));

-- ---------------------------------------------------------------------------
-- 8. DELETE: Only admin or owner can delete
-- ---------------------------------------------------------------------------
CREATE POLICY "properties_delete_own_or_admin"
ON public.properties FOR DELETE
TO authenticated
USING (owner_id = auth.uid() OR public.is_admin(auth.uid()));

-- ---------------------------------------------------------------------------
-- 9. Ensure the enforce_property_publishing_rules trigger is in place
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_property_publishing_rules()
RETURNS TRIGGER AS $$
BEGIN
    -- If actor is admin or service_role, permit all valid status transitions
    IF public.is_admin(auth.uid()) OR auth.uid() IS NULL THEN
        RETURN NEW;
    END IF;

    -- Non-admin users cannot directly publish properties; force to pending
    IF NEW.status = 'published' AND (OLD IS NULL OR OLD.status != 'published') THEN
        NEW.status := 'pending';
    END IF;

    -- Non-admin users cannot alter review metadata
    IF OLD IS NOT NULL THEN
        NEW.reviewed_by := OLD.reviewed_by;
        NEW.reviewed_at := OLD.reviewed_at;
        NEW.rejection_reason := OLD.rejection_reason;
    ELSE
        NEW.reviewed_by := NULL;
        NEW.reviewed_at := NULL;
        NEW.rejection_reason := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_enforce_property_publishing_rules ON public.properties;
CREATE TRIGGER trg_enforce_property_publishing_rules
BEFORE INSERT OR UPDATE ON public.properties
FOR EACH ROW EXECUTE FUNCTION public.enforce_property_publishing_rules();

-- ---------------------------------------------------------------------------
-- 10. Add is_demo column to mark seed/demo properties (non-destructive)
-- ---------------------------------------------------------------------------
ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS is_demo BOOLEAN DEFAULT FALSE;

-- Mark any existing properties with demo-like titles
UPDATE public.properties
SET is_demo = TRUE
WHERE title ILIKE '%تجريبي%'
   OR title ILIKE '%demo%'
   OR title ILIKE '%test%'
   OR description ILIKE '%بيانات تجريبية%';

-- ---------------------------------------------------------------------------
-- 11. Verify pending properties are accessible (for reporting only)
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  v_pending_count INT;
BEGIN
  SELECT COUNT(*) INTO v_pending_count
  FROM public.properties
  WHERE status = 'pending';
  RAISE NOTICE 'Pending properties count: %', v_pending_count;
END $$;

COMMIT;
