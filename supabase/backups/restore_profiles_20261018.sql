-- ==============================================================================
-- Restore Script: Profiles Backup Snapshot 2026-10-18
-- Target: Yemen Real Estate Portal (بوابة اليمن العقارية)
-- ==============================================================================

INSERT INTO public.profiles (id, full_name, phone, avatar_url, role, is_verified, created_at, updated_at)
VALUES 
    ('fc1c34b0-156a-4abb-98e8-95e5c0bdf2c7', 'عيبده مصلح ناجي السقاف', '779986145', NULL, 'user', FALSE, '2026-10-17T19:41:06.133335+00:00'::timestamptz, '2026-10-17T19:41:06.133335+00:00'::timestamptz),
    ('5356d901-f84f-4be0-80d4-60e19771ad08', 'محمد علي محمد علي', '777796853', NULL, 'user', FALSE, '2026-10-17T23:34:07.513387+00:00'::timestamptz, '2026-10-17T23:34:07.513387+00:00'::timestamptz),
    ('daa0d684-f82b-4878-9d86-ce2810be9786', 'محمد السقاف', '772606709', NULL, 'user', FALSE, '2026-10-18T01:27:02.188347+00:00'::timestamptz, '2026-10-18T01:27:02.188347+00:00'::timestamptz)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    avatar_url = EXCLUDED.avatar_url,
    role = EXCLUDED.role,
    is_verified = EXCLUDED.is_verified,
    updated_at = EXCLUDED.updated_at;
