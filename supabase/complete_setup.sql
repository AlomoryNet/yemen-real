-- ==============================================================================
-- Yemen Real Estate Portal — بوابة اليمن العقارية
-- Consolidated Complete Setup for Supabase
-- Contains:
-- 1. Database Schema & Tables (12 tables)
-- 2. Performance Indexes & Triggers
-- 3. Row Level Security (RLS) Policies
-- 4. Storage Bucket & Storage RLS Policies
-- 5. Seed Data (Property Types, Yemen Locations, Platform Settings)
-- ==============================================================================

-- ==============================================================================
-- Yemen Real Estate Portal — بوابة اليمن العقارية
-- Database Schema & Security Setup (Supabase / PostgreSQL)
-- Migration: 20261016_initial_schema.sql
-- ==============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 1. Profiles Table (Linked to auth.users)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin', 'super_admin')),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 2. Property Types Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.property_types (
    id TEXT PRIMARY KEY,
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    icon TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 3. Locations Table (Governorates & Districts in Yemen)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    parent_id UUID REFERENCES public.locations(id) ON DELETE SET NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 4. Properties Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    deal_type TEXT NOT NULL CHECK (deal_type IN ('sale', 'rent')),
    property_type_id TEXT NOT NULL REFERENCES public.property_types(id),
    location_id UUID REFERENCES public.locations(id) ON DELETE SET NULL,
    city TEXT NOT NULL,
    district TEXT NOT NULL,
    address_details TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    price NUMERIC(15, 2) NOT NULL CHECK (price >= 0),
    currency TEXT NOT NULL DEFAULT 'YER' CHECK (currency IN ('YER', 'SAR', 'USD')),
    area_sqm NUMERIC(10, 2) NOT NULL CHECK (area_sqm > 0),
    bedrooms INT NOT NULL DEFAULT 0 CHECK (bedrooms >= 0),
    bathrooms INT NOT NULL DEFAULT 0 CHECK (bathrooms >= 0),
    contact_phone TEXT NOT NULL,
    contact_whatsapp TEXT,
    status TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'hidden', 'archived', 'rejected')),
    publishing_mode TEXT NOT NULL DEFAULT 'self_review',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    views_count INT NOT NULL DEFAULT 0,
    has_ownership_pledge BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 5. Property Images Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.property_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 6. Favorites Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_property_favorite UNIQUE (user_id, property_id)
);

-- ==============================================================================
-- 7. Rental Requests Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.rental_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_number TEXT NOT NULL UNIQUE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    requested_start_date DATE,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'under_review', 'contacted', 'provisionally_accepted', 'rejected', 'cancelled', 'completed')),
    admin_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 8. Commissions Table (Administrative Manual Records)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    liable_party TEXT NOT NULL CHECK (liable_party IN ('seller', 'buyer', 'both')),
    seller_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (seller_amount >= 0),
    buyer_amount NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (buyer_amount >= 0),
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    currency TEXT NOT NULL DEFAULT 'YER' CHECK (currency IN ('YER', 'SAR', 'USD')),
    reason_and_notes TEXT,
    settlement_status TEXT NOT NULL DEFAULT 'due' CHECK (settlement_status IN ('due', 'paid', 'cancelled')),
    settlement_method TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    settled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 9. Reports Table (Violating Ads Reporting)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    admin_action_taken TEXT,
    resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ==============================================================================
-- 10. Platform Settings Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.platform_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 11. Audit Logs Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    target_entity TEXT NOT NULL,
    target_id TEXT,
    details JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 12. In-App Notifications Table
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    link TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- Indexes for Performance
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_properties_status ON public.properties(status);
CREATE INDEX IF NOT EXISTS idx_properties_deal_type ON public.properties(deal_type);
CREATE INDEX IF NOT EXISTS idx_properties_property_type ON public.properties(property_type_id);
CREATE INDEX IF NOT EXISTS idx_properties_city ON public.properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_price ON public.properties(price);
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON public.properties(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_property_images_property_id ON public.property_images(property_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_rental_requests_user ON public.rental_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_rental_requests_property ON public.rental_requests(property_id);
CREATE INDEX IF NOT EXISTS idx_commissions_property ON public.commissions(property_id);
CREATE INDEX IF NOT EXISTS idx_reports_property ON public.reports(property_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- ==============================================================================
-- Automatic updated_at Trigger Function
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_properties_updated_at
BEFORE UPDATE ON public.properties
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_rental_requests_updated_at
BEFORE UPDATE ON public.rental_requests
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER trg_commissions_updated_at
BEFORE UPDATE ON public.commissions
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- Helper Security Definer Functions (Prevents RLS recursion)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = user_id AND role IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Automatic User Profile Creation on Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
        NEW.raw_user_meta_data->>'phone',
        'user'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper function for Audit Logging
CREATE OR REPLACE FUNCTION public.log_audit_event(
    p_action TEXT,
    p_target_entity TEXT,
    p_target_id TEXT DEFAULT NULL,
    p_details JSONB DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.audit_logs (actor_id, action, target_entity, target_id, details)
    VALUES (auth.uid(), p_action, p_target_entity, p_target_id, p_details);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rental_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- Profiles Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Public profiles are viewable by everyone"
ON public.profiles FOR SELECT
USING (true);

CREATE POLICY "Users can update own profile except role"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (
    auth.uid() = id
    AND (
        role = (SELECT role FROM public.profiles WHERE id = auth.uid())
        OR public.is_admin(auth.uid())
    )
);

CREATE POLICY "Admins can update any profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Property Types & Locations Policies (Public read, admin write)
-- ------------------------------------------------------------------------------
CREATE POLICY "Property types viewable by everyone"
ON public.property_types FOR SELECT
USING (is_active = TRUE OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage property types"
ON public.property_types FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

CREATE POLICY "Locations viewable by everyone"
ON public.locations FOR SELECT
USING (is_active = TRUE OR public.is_admin(auth.uid()));

CREATE POLICY "Admins manage locations"
ON public.locations FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Properties Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Public can view published properties"
ON public.properties FOR SELECT
USING (
    status = 'published'
    OR (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_admin(auth.uid())
);

CREATE POLICY "Authenticated users can insert own properties"
ON public.properties FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners and admins can update properties"
ON public.properties FOR UPDATE
TO authenticated
USING (
    auth.uid() = owner_id
    OR public.is_admin(auth.uid())
)
WITH CHECK (
    auth.uid() = owner_id
    OR public.is_admin(auth.uid())
);

CREATE POLICY "Owners and admins can delete properties"
ON public.properties FOR DELETE
TO authenticated
USING (
    auth.uid() = owner_id
    OR public.is_admin(auth.uid())
);

-- ------------------------------------------------------------------------------
-- Property Images Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Property images viewable by everyone"
ON public.property_images FOR SELECT
USING (true);

CREATE POLICY "Owners and admins can insert property images"
ON public.property_images FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND (p.owner_id = auth.uid() OR public.is_admin(auth.uid()))
    )
);

CREATE POLICY "Owners and admins can update property images"
ON public.property_images FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND (p.owner_id = auth.uid() OR public.is_admin(auth.uid()))
    )
);

CREATE POLICY "Owners and admins can delete property images"
ON public.property_images FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND (p.owner_id = auth.uid() OR public.is_admin(auth.uid()))
    )
);

-- ------------------------------------------------------------------------------
-- Favorites Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view own favorites"
ON public.favorites FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can add own favorites"
ON public.favorites FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove own favorites"
ON public.favorites FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- Rental Requests Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view own rental requests"
ON public.rental_requests FOR SELECT
TO authenticated
USING (
    auth.uid() = user_id
    OR EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
    OR public.is_admin(auth.uid())
);

CREATE POLICY "Authenticated users can submit rental requests"
ON public.rental_requests FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners and admins can update rental request status"
ON public.rental_requests FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND p.owner_id = auth.uid()
    )
    OR public.is_admin(auth.uid())
);

-- ------------------------------------------------------------------------------
-- Commissions Policies (Admin ONLY)
-- ------------------------------------------------------------------------------
CREATE POLICY "Admins can manage commissions"
ON public.commissions FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Reports Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Anyone authenticated or guest can submit reports"
ON public.reports FOR INSERT
WITH CHECK (true);

CREATE POLICY "Admins can view and manage reports"
ON public.reports FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Platform Settings Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Platform settings viewable by everyone"
ON public.platform_settings FOR SELECT
USING (true);

CREATE POLICY "Admins can manage platform settings"
ON public.platform_settings FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Audit Logs Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Admins can view audit logs"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Notifications Policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view own notifications"
ON public.notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);


-- ==============================================================================
-- STORAGE BUCKETS & POLICIES
-- ==============================================================================
-- ==============================================================================
-- Yemen Real Estate Portal — بوابة اليمن العقارية
-- Supabase Storage Setup & Security Policies
-- File: supabase/storage_setup.sql
-- ==============================================================================

-- 1. Create the 'property-images' storage bucket if it doesn't already exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'property-images',
    'property-images',
    true,
    5242880, -- 5 MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE 
SET public = true, file_size_limit = 5242880;

-- 2. Storage Policies

-- Public Read access
CREATE POLICY "Public can view property images"
ON storage.objects FOR SELECT
USING (bucket_id = 'property-images');

-- Authenticated Users Upload access
CREATE POLICY "Authenticated users can upload property images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'property-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Owners and Admins Update access
CREATE POLICY "Owners and admins can update property images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'property-images'
    AND (
        (storage.foldername(name))[1] = auth.uid()::text
        OR public.is_admin(auth.uid())
    )
);

-- Owners and Admins Delete access
CREATE POLICY "Owners and admins can delete property images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'property-images'
    AND (
        (storage.foldername(name))[1] = auth.uid()::text
        OR public.is_admin(auth.uid())
    )
);


-- ==============================================================================
-- SEED DATA (PROPERTY TYPES, LOCATIONS, SETTINGS)
-- ==============================================================================
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

