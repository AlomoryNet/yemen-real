-- ==============================================================================
-- Yemen Real Estate Portal — بوابة اليمن العقارية
-- Seed Data: Property Types, Locations, and Default Settings
-- File: supabase/seed.sql
-- ==============================================================================

-- 1. Property Types
INSERT INTO public.property_types (id, name_ar, name_en, icon, sort_order, is_active)
VALUES
    ('apartment', 'شقق سكنية', 'Apartments', 'apartment', 1, true),
    ('villa', 'فلل ومنازل', 'Villas & Houses', 'villa', 2, true),
    ('land', 'أراضٍ', 'Lands', 'terrain', 3, true),
    ('shop', 'محلات تجارية', 'Commercial Shops', 'storefront', 4, true),
    ('office', 'مكاتب ومبانٍ تجارية', 'Offices & Commercial Buildings', 'business', 5, true),
    ('other', 'عقارات أخرى', 'Other Properties', 'more_horiz', 6, true)
ON CONFLICT (id) DO UPDATE 
SET name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en, icon = EXCLUDED.icon;

-- 2. Locations (Geographic Scope: Capital Sana'a with its key districts, expandable)
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('10000000-0000-0000-0000-000000000001', 'أمانة العاصمة صنعاء', 'Sanaa Capital', NULL, 15.3694, 44.1910, 1, true),
    ('10000000-0000-0000-0000-000000000002', 'محافظة عدن', 'Aden Governorate', NULL, 12.7855, 45.0187, 2, true),
    ('10000000-0000-0000-0000-000000000003', 'محافظة تعز', 'Taiz Governorate', NULL, 13.5776, 44.0186, 3, true)
ON CONFLICT (id) DO NOTHING;

-- Sana'a Districts
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000001', 'حدة والحي الدبلوماسي', 'Hadda & Diplomatic Quarter', '10000000-0000-0000-0000-000000000001', 15.3188, 44.1853, 1, true),
    ('20000000-0000-0000-0000-000000000002', 'السبعين', 'Al Sabeen', '10000000-0000-0000-0000-000000000001', 15.3262, 44.2059, 2, true),
    ('20000000-0000-0000-0000-000000000003', 'الأصبحي', 'Al Asbahi', '10000000-0000-0000-0000-000000000001', 15.3087, 44.2173, 3, true),
    ('20000000-0000-0000-0000-000000000004', 'بيت بوس', 'Bait Baws', '10000000-0000-0000-0000-000000000001', 15.2891, 44.1984, 4, true),
    ('20000000-0000-0000-0000-000000000005', 'الصافية', 'Al Safiyah', '10000000-0000-0000-0000-000000000001', 15.3421, 44.2189, 5, true),
    ('20000000-0000-0000-0000-000000000006', 'الستين الغربي', 'West 60th St', '10000000-0000-0000-0000-000000000001', 15.3620, 44.1750, 6, true),
    ('20000000-0000-0000-0000-000000000007', 'شملان ومذبح', 'Shamlan & Mathbah', '10000000-0000-0000-0000-000000000001', 15.3950, 44.1560, 7, true),
    ('20000000-0000-0000-0000-000000000008', 'دار سلم ودار الحيد', 'Dar Silm', '10000000-0000-0000-0000-000000000001', 15.2670, 44.2230, 8, true)
ON CONFLICT (id) DO NOTHING;

-- 3. Platform Settings
INSERT INTO public.platform_settings (key, value, description)
VALUES
    ('portal_identity', '{
        "name_ar": "بوابة اليمن العقارية",
        "name_en": "Yemen Real Estate Portal",
        "tagline_ar": "منصتك الموثوقة لاستئجار وشراء وبيع العقارات في اليمن",
        "contact_phone": "+967 770 000 000",
        "contact_whatsapp": "967770000000",
        "contact_email": "info@yemenrealestate.local"
    }', 'Platform branding and identity settings'),
    ('commission_policy', '{
        "mode": "manual",
        "liable_party": "both",
        "description_ar": "يتم تحديد العمولة يدوياً وتوثيقها إدارياً بحسب الاتفاق المبرم لكل صفقة، دون اقتطاع إلكتروني مباشر."
    }', 'Commission terms and policy disclaimer'),
    ('publishing_policy', '{
        "mode": "self_review",
        "notice_ar": "يتحمل المعلن المسؤولية الكاملة عن صحة بيانات الإعلان، وللإدارة الحق في حجب أو إزالة أي إعلان مخالف."
    }', 'Property publishing guidelines')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- ==============================================================================
-- Instructions to Promote the First Admin:
-- Run this query in Supabase SQL Editor after the admin user signs up:
--
-- UPDATE public.profiles
-- SET role = 'super_admin', is_verified = TRUE
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@yemenrealestate.local');
-- ==============================================================================
