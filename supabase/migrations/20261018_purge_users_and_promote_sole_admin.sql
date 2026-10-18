-- ==============================================================================
-- Migration & Maintenance: User Purge & Sole Administrator Promotion
-- Target: Yemen Real Estate Portal (بوابة اليمن العقارية)
-- Target Project: https://fwpckpzrhvvxltdiiatn.supabase.co
-- Sole Publishing Administrator: Eng. Mohammed Al-Saqqaf (mo772522233@gmail.com)
-- Target UUID: daa0d684-f82b-4878-9d86-ce2810be9786
-- ==============================================================================

BEGIN;

-- 1. Ensure profiles table has email column before block execution
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

DO $$
DECLARE
    v_admin_id CONSTANT UUID := 'daa0d684-f82b-4878-9d86-ce2810be9786'::UUID;
    v_admin_email CONSTANT TEXT := 'mo772522233@gmail.com';
    v_deleted_auth_users INT := 0;
    v_deleted_profiles INT := 0;
BEGIN
    -- 1. Ensure administrator exists in auth.users
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'auth' AND table_name = 'users'
    ) THEN
        IF NOT EXISTS (
            SELECT 1 FROM auth.users WHERE id = v_admin_id OR lower(email) = lower(v_admin_email)
        ) THEN
            RAISE EXCEPTION 'MIGRATION ABORTED: Administrator with UUID % or email % does not exist in auth.users.', v_admin_id, v_admin_email;
        END IF;

        -- Ensure admin email is confirmed and updated
        UPDATE auth.users
        SET 
            email = v_admin_email,
            email_confirmed_at = COALESCE(email_confirmed_at, pg_catalog.now()),
            updated_at = pg_catalog.now()
        WHERE id = v_admin_id;

        -- 2. Safely remove non-admin application user accounts from auth.users
        WITH deleted AS (
            DELETE FROM auth.users
            WHERE id <> v_admin_id AND lower(email) <> lower(v_admin_email)
            RETURNING id
        )
        SELECT COUNT(*) INTO v_deleted_auth_users FROM deleted;
        RAISE NOTICE 'Deleted % non-admin user accounts from auth.users.', v_deleted_auth_users;
    END IF;

    -- 3. Safely remove non-admin profiles if not cascaded
    WITH deleted_p AS (
        DELETE FROM public.profiles
        WHERE id <> v_admin_id AND (email IS NULL OR lower(email) <> lower(v_admin_email))
        RETURNING id
    )
    SELECT COUNT(*) INTO v_deleted_profiles FROM deleted_p;
    RAISE NOTICE 'Deleted % non-admin profiles from public.profiles.', v_deleted_profiles;

    -- 5. Promote Sole Administrator profile to super_admin and verified
    UPDATE public.profiles
    SET 
        full_name = 'م/محمد السقاف',
        email = v_admin_email,
        phone = COALESCE(phone, '772522233'),
        role = 'super_admin',
        is_verified = TRUE,
        updated_at = pg_catalog.now()
    WHERE id = v_admin_id;

    IF NOT FOUND THEN
        INSERT INTO public.profiles (id, full_name, email, phone, role, is_verified, created_at, updated_at)
        VALUES (v_admin_id, 'م/محمد السقاف', v_admin_email, '772522233', 'super_admin', TRUE, pg_catalog.now(), pg_catalog.now());
    END IF;

    RAISE NOTICE 'Sole Administrator (%) successfully confirmed and promoted to super_admin.', v_admin_email;
END $$;

COMMIT;
