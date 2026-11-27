-- ==============================================================================
-- Migration: Purge All Users & Establish Sole Super Administrator
-- Target: Yemen Real Estate Portal (بوابة اليمن العقارية)
-- Supabase Project: https://<supabase-project>.supabase.co
-- Sole Administrator: mo772522233@gmail.com
-- Password: 772606709
-- ==============================================================================

BEGIN;

-- Enable pgcrypto extension for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Ensure profiles table has required columns
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;

DO $$
DECLARE
    v_admin_email CONSTANT TEXT := 'mo772522233@gmail.com';
    v_admin_password CONSTANT TEXT := '772606709';
    v_admin_phone CONSTANT TEXT := '772606709';
    v_admin_name CONSTANT TEXT := 'م/محمد السقاف';
    v_admin_id UUID;
    v_encrypted_pw TEXT;
    v_deleted_users INT := 0;
    v_deleted_profiles INT := 0;
BEGIN
    -- 1. Compute bcrypt password hash for the specified password
    v_encrypted_pw := crypt(v_admin_password, gen_salt('bf', 10));

    -- 2. Find existing admin user ID if already present in auth.users
    SELECT id INTO v_admin_id
    FROM auth.users
    WHERE lower(email) = lower(v_admin_email)
    LIMIT 1;

    -- 3. If admin does not exist in auth.users, create new user account
    IF v_admin_id IS NULL THEN
        v_admin_id := gen_random_uuid();
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            confirmation_token,
            recovery_token
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            v_admin_id,
            'authenticated',
            'authenticated',
            lower(v_admin_email),
            v_encrypted_pw,
            pg_catalog.now(),
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object('full_name', v_admin_name, 'phone', v_admin_phone),
            pg_catalog.now(),
            pg_catalog.now(),
            '',
            ''
        );
        RAISE NOTICE 'Created new auth user for sole administrator: % with ID %', v_admin_email, v_admin_id;
    ELSE
        -- Update existing admin password and confirm email
        UPDATE auth.users
        SET
            encrypted_password = v_encrypted_pw,
            email_confirmed_at = COALESCE(email_confirmed_at, pg_catalog.now()),
            raw_user_meta_data = jsonb_build_object('full_name', v_admin_name, 'phone', v_admin_phone),
            updated_at = pg_catalog.now()
        WHERE id = v_admin_id;
        RAISE NOTICE 'Updated existing auth user for sole administrator: % with ID %', v_admin_email, v_admin_id;
    END IF;

    -- 4. Purge all other users from auth.users
    WITH deleted_auth AS (
        DELETE FROM auth.users
        WHERE id <> v_admin_id AND lower(email) <> lower(v_admin_email)
        RETURNING id
    )
    SELECT COUNT(*) INTO v_deleted_users FROM deleted_auth;
    RAISE NOTICE 'Purged % other user accounts from auth.users.', v_deleted_users;

    -- 5. Purge all other profiles from public.profiles
    WITH deleted_prof AS (
        DELETE FROM public.profiles
        WHERE id <> v_admin_id
        RETURNING id
    )
    SELECT COUNT(*) INTO v_deleted_profiles FROM deleted_prof;
    RAISE NOTICE 'Purged % non-admin profiles from public.profiles.', v_deleted_profiles;

    -- 6. Upsert the sole administrator profile with super_admin role and verified status
    INSERT INTO public.profiles (
        id,
        full_name,
        email,
        phone,
        role,
        is_verified,
        created_at,
        updated_at
    ) VALUES (
        v_admin_id,
        v_admin_name,
        lower(v_admin_email),
        v_admin_phone,
        'super_admin',
        TRUE,
        pg_catalog.now(),
        pg_catalog.now()
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        phone = EXCLUDED.phone,
        role = 'super_admin',
        is_verified = TRUE,
        updated_at = pg_catalog.now();

    RAISE NOTICE 'Sole Super Administrator confirmed: email=%, phone=%, role=super_admin', v_admin_email, v_admin_phone;
END $$;

COMMIT;
