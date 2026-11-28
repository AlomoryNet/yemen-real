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
-- Schema upgrades for the current app lifecycle (idempotent)
-- ==============================================================================
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.properties
ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS images_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Drop any existing status CHECK so older databases accept the full lifecycle.
DO $$
DECLARE
    constraint_row RECORD;
BEGIN
    FOR constraint_row IN
        SELECT conname
        FROM pg_constraint
        WHERE conrelid = 'public.properties'::regclass
          AND contype = 'c'
          AND pg_get_constraintdef(oid) ILIKE '%status%'
    LOOP
        EXECUTE format('ALTER TABLE public.properties DROP CONSTRAINT %I', constraint_row.conname);
    END LOOP;
END $$;

ALTER TABLE public.properties
ADD CONSTRAINT chk_properties_status
CHECK (status IN ('draft', 'pending', 'published', 'hidden', 'archived', 'rejected'));

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

-- Regular users cannot publish directly; their submissions enter review.
CREATE OR REPLACE FUNCTION public.enforce_property_publishing_rules()
RETURNS TRIGGER AS $$
BEGIN
    IF public.is_admin(auth.uid()) OR auth.uid() IS NULL THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' AND NEW.status = 'published' THEN
        NEW.status := 'pending';
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'published'
          AND OLD.status IS DISTINCT FROM 'published' THEN
        NEW.status := 'pending';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.reviewed_by := OLD.reviewed_by;
        NEW.reviewed_at := OLD.reviewed_at;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_enforce_property_publishing_rules ON public.properties;
CREATE TRIGGER trg_enforce_property_publishing_rules
BEFORE INSERT OR UPDATE ON public.properties
FOR EACH ROW EXECUTE FUNCTION public.enforce_property_publishing_rules();

-- Automatic User Profile Creation on Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, phone, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
        NEW.email,
        NEW.raw_user_meta_data->>'phone',
        'user'
    )
    ON CONFLICT (id) DO UPDATE SET
        email = COALESCE(public.profiles.email, EXCLUDED.email);
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

-- View counter RPC used by PropertyRepository.getPropertyById().
CREATE OR REPLACE FUNCTION public.increment_property_views(prop_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.properties
    SET views_count = COALESCE(views_count, 0) + 1
    WHERE id = prop_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.increment_property_views(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.increment_property_views(UUID) TO anon, authenticated;

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

-- Explicit role grants. RLS still decides which rows each role can see.
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated, service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT INSERT ON public.reports TO anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- ------------------------------------------------------------------------------
-- Profiles Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone"
ON public.profiles FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Users can update own profile except role" ON public.profiles;
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

DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
CREATE POLICY "Admins can update any profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Property Types & Locations Policies (Public read, admin write)
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Property types viewable by everyone" ON public.property_types;
CREATE POLICY "Property types viewable by everyone"
ON public.property_types FOR SELECT
USING (is_active = TRUE OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage property types" ON public.property_types;
CREATE POLICY "Admins manage property types"
ON public.property_types FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Locations viewable by everyone" ON public.locations;
CREATE POLICY "Locations viewable by everyone"
ON public.locations FOR SELECT
USING (is_active = TRUE OR public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage locations" ON public.locations;
CREATE POLICY "Admins manage locations"
ON public.locations FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Properties Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can view published properties" ON public.properties;
CREATE POLICY "Public can view published properties"
ON public.properties FOR SELECT
USING (
    status = 'published'
    OR (auth.uid() IS NOT NULL AND owner_id = auth.uid())
    OR public.is_admin(auth.uid())
);

DROP POLICY IF EXISTS "Authenticated users can insert own properties" ON public.properties;
CREATE POLICY "Authenticated users can insert own properties"
ON public.properties FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owners and admins can update properties" ON public.properties;
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

DROP POLICY IF EXISTS "Owners and admins can delete properties" ON public.properties;
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
DROP POLICY IF EXISTS "Property images viewable by everyone" ON public.property_images;
CREATE POLICY "Property images viewable by everyone"
ON public.property_images FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Owners and admins can insert property images" ON public.property_images;
CREATE POLICY "Owners and admins can insert property images"
ON public.property_images FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND (p.owner_id = auth.uid() OR public.is_admin(auth.uid()))
    )
);

DROP POLICY IF EXISTS "Owners and admins can update property images" ON public.property_images;
CREATE POLICY "Owners and admins can update property images"
ON public.property_images FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.properties p
        WHERE p.id = property_id AND (p.owner_id = auth.uid() OR public.is_admin(auth.uid()))
    )
);

DROP POLICY IF EXISTS "Owners and admins can delete property images" ON public.property_images;
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
DROP POLICY IF EXISTS "Users can view own favorites" ON public.favorites;
CREATE POLICY "Users can view own favorites"
ON public.favorites FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can add own favorites" ON public.favorites;
CREATE POLICY "Users can add own favorites"
ON public.favorites FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can remove own favorites" ON public.favorites;
CREATE POLICY "Users can remove own favorites"
ON public.favorites FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- Rental Requests Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own rental requests" ON public.rental_requests;
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

DROP POLICY IF EXISTS "Authenticated users can submit rental requests" ON public.rental_requests;
CREATE POLICY "Authenticated users can submit rental requests"
ON public.rental_requests FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owners and admins can update rental request status" ON public.rental_requests;
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
DROP POLICY IF EXISTS "Admins can manage commissions" ON public.commissions;
CREATE POLICY "Admins can manage commissions"
ON public.commissions FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Reports Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Anyone authenticated or guest can submit reports" ON public.reports;
CREATE POLICY "Anyone authenticated or guest can submit reports"
ON public.reports FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Admins can view and manage reports" ON public.reports;
CREATE POLICY "Admins can view and manage reports"
ON public.reports FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Platform Settings Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Platform settings viewable by everyone" ON public.platform_settings;
CREATE POLICY "Platform settings viewable by everyone"
ON public.platform_settings FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Admins can manage platform settings" ON public.platform_settings;
CREATE POLICY "Admins can manage platform settings"
ON public.platform_settings FOR ALL
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Audit Logs Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Admins can view audit logs" ON public.audit_logs;
CREATE POLICY "Admins can view audit logs"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- Notifications Policies
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications"
ON public.notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);


-- ==============================================================================
-- Saved Searches & New-Listing Alerts (also in
-- supabase/migrations/20261128_saved_searches_and_alerts.sql)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.saved_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    query JSONB NOT NULL DEFAULT '{}'::jsonb,
    notify BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_saved_searches_user_created
    ON public.saved_searches(user_id, created_at DESC);

ALTER TABLE public.saved_searches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own saved searches" ON public.saved_searches;
CREATE POLICY "Users can view own saved searches"
ON public.saved_searches FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can add own saved searches" ON public.saved_searches;
CREATE POLICY "Users can add own saved searches"
ON public.saved_searches FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own saved searches" ON public.saved_searches;
CREATE POLICY "Users can update own saved searches"
ON public.saved_searches FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own saved searches" ON public.saved_searches;
CREATE POLICY "Users can delete own saved searches"
ON public.saved_searches FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.notify_saved_search_matches()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    saved public.saved_searches;
    q JSONB;
    search_text TEXT;
    property_lat DOUBLE PRECISION;
    property_lng DOUBLE PRECISION;
    center_lat DOUBLE PRECISION;
    center_lng DOUBLE PRECISION;
    saved_radius DOUBLE PRECISION;
    match_distance DOUBLE PRECISION;
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    IF NEW.status <> 'published' THEN
        RETURN NEW;
    END IF;

    search_text := LOWER(
        CONCAT_WS(' ', NEW.title, NEW.city, NEW.district, COALESCE(NEW.address_details, ''))
    );

    FOR saved IN
        SELECT * FROM public.saved_searches
        WHERE notify = TRUE AND user_id <> NEW.owner_id
    LOOP
        q := saved.query;

        IF q->>'dealType' IS NOT NULL
           AND q->>'dealType' <> ''
           AND NEW.deal_type <> q->>'dealType' THEN
            CONTINUE;
        END IF;

        IF q->>'propertyTypeId' IS NOT NULL
           AND NEW.property_type_id <> q->>'propertyTypeId' THEN
            CONTINUE;
        END IF;

        IF q->>'governorate' IS NOT NULL AND q->>'governorate' <> '' THEN
            IF NOT (
                NEW.city = q->>'governorate'
                OR POSITION(q->>'governorate' IN NEW.city) > 0
                OR POSITION(NEW.city IN q->>'governorate') > 0
                OR (
                    q->>'governorate' IN ('صنعاء', 'أمانة العاصمة')
                    AND NEW.city IN ('صنعاء', 'أمانة العاصمة')
                )
            ) THEN
                CONTINUE;
            END IF;
        END IF;

        IF q->>'district' IS NOT NULL AND q->>'district' <> ''
           AND POSITION(LOWER(q->>'district') IN LOWER(NEW.district)) = 0
           AND POSITION(LOWER(NEW.district) IN LOWER(q->>'district')) = 0 THEN
            CONTINUE;
        END IF;

        IF q->>'freeText' IS NOT NULL AND TRIM(q->>'freeText') <> ''
           AND search_text NOT LIKE '%' || LOWER(TRIM(q->>'freeText')) || '%' THEN
            CONTINUE;
        END IF;

        IF q->>'minPrice' IS NOT NULL
           AND NEW.price < (q->>'minPrice')::numeric THEN
            CONTINUE;
        END IF;

        IF q->>'maxPrice' IS NOT NULL
           AND NEW.price > (q->>'maxPrice')::numeric THEN
            CONTINUE;
        END IF;

        IF q->>'minBedrooms' IS NOT NULL
           AND NEW.bedrooms < (q->>'minBedrooms')::integer THEN
            CONTINUE;
        END IF;

        IF q->>'onlyFeatured' = 'true' AND NOT NEW.is_featured THEN
            CONTINUE;
        END IF;

        IF q->>'onlyExactCoordinates' = 'true'
           AND (
                NEW.latitude IS NULL OR NEW.longitude IS NULL
                OR NEW.latitude = 0 OR NEW.longitude = 0
           ) THEN
            CONTINUE;
        END IF;

        IF q->>'nearbyLatitude' IS NOT NULL
           AND q->>'nearbyLongitude' IS NOT NULL
           AND q->>'radiusKm' IS NOT NULL THEN
            center_lat := (q->>'nearbyLatitude')::double precision;
            center_lng := (q->>'nearbyLongitude')::double precision;
            saved_radius := (q->>'radiusKm')::double precision;
            property_lat := NEW.latitude;
            property_lng := NEW.longitude;

            -- Matches the app's governorate-center fallback for listings
            -- without their own coordinates.
            IF property_lat IS NULL OR property_lng IS NULL
               OR property_lat = 0 OR property_lng = 0 THEN
                SELECT l.latitude, l.longitude
                  INTO property_lat, property_lng
                  FROM public.locations l
                 WHERE l.parent_id IS NULL
                   AND (
                     l.name_ar = NEW.city OR l.name_en = NEW.city
                     OR POSITION(NEW.city IN l.name_ar) > 0
                     OR POSITION(l.name_ar IN NEW.city) > 0
                   )
                 ORDER BY CASE
                            WHEN l.name_ar = NEW.city OR l.name_en = NEW.city
                            THEN 0 ELSE 1
                          END
                 LIMIT 1;
            END IF;

            IF property_lat IS NULL OR property_lng IS NULL THEN
                CONTINUE;
            END IF;

            match_distance := 6371 * 2 * ASIN(
                SQRT(
                    POWER(SIN(RADIANS(property_lat - center_lat) / 2), 2)
                    + COS(RADIANS(center_lat)) * COS(RADIANS(property_lat))
                      * POWER(SIN(RADIANS(property_lng - center_lng) / 2), 2)
                )
            );

            IF match_distance > saved_radius THEN
                CONTINUE;
            END IF;
        END IF;

        INSERT INTO public.notifications (user_id, title, body, link)
        SELECT
            saved.user_id,
            'عقار جديد يطابق بحثك',
            'ظهر إعلان جديد يطابق بحثك المحفوظ: ' || saved.name,
            '/property/' || NEW.id::text
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.notifications n
            WHERE n.user_id = saved.user_id
              AND n.link = '/property/' || NEW.id::text
              AND n.created_at > NOW() - INTERVAL '30 days'
        );
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_saved_search_matches ON public.properties;
CREATE TRIGGER trg_notify_saved_search_matches
AFTER INSERT OR UPDATE OF status ON public.properties
FOR EACH ROW
WHEN (NEW.status = 'published')
EXECUTE FUNCTION public.notify_saved_search_matches();

GRANT USAGE ON SCHEMA public TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.saved_searches TO authenticated, service_role;
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
GRANT EXECUTE ON FUNCTION public.notify_saved_search_matches() TO authenticated, service_role;

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
DROP POLICY IF EXISTS "Public can view property images" ON storage.objects;
CREATE POLICY "Public can view property images"
ON storage.objects FOR SELECT
USING (bucket_id = 'property-images');

-- Authenticated Users Upload access
DROP POLICY IF EXISTS "Authenticated users can upload property images" ON storage.objects;
CREATE POLICY "Authenticated users can upload property images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'property-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Owners and Admins Update access
DROP POLICY IF EXISTS "Owners and admins can update property images" ON storage.objects;
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
DROP POLICY IF EXISTS "Owners and admins can delete property images" ON storage.objects;
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

-- Remaining governorates. Coordinates are practical centroids used by the
-- app when a listing has no exact pin; district rows below are approximate
-- district centres and can be refined locally without changing their IDs.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('10000000-0000-0000-0000-000000000004', 'محافظة صنعاء', 'Sanaa Governorate', NULL, 15.2200, 44.3500, 4, true),
    ('10000000-0000-0000-0000-000000000005', 'حضرموت', 'Hadramaut Governorate', NULL, 14.5425, 49.1242, 5, true),
    ('10000000-0000-0000-0000-000000000006', 'إب', 'Ibb Governorate', NULL, 13.9667, 44.1833, 6, true),
    ('10000000-0000-0000-0000-000000000007', 'الحديدة', 'Al Hudaydah Governorate', NULL, 14.7978, 42.9545, 7, true),
    ('10000000-0000-0000-0000-000000000008', 'مأرب', 'Marib Governorate', NULL, 15.4624, 45.3258, 8, true),
    ('10000000-0000-0000-0000-000000000009', 'ذمار', 'Dhamar Governorate', NULL, 14.5427, 44.4051, 9, true),
    ('10000000-0000-0000-0000-000000000010', 'شبوة', 'Shabwah Governorate', NULL, 14.5377, 46.8319, 10, true),
    ('10000000-0000-0000-0000-000000000011', 'لحج', 'Lahij Governorate', NULL, 13.0583, 44.8828, 11, true),
    ('10000000-0000-0000-0000-000000000012', 'أبين', 'Abyan Governorate', NULL, 13.1287, 45.3805, 12, true),
    ('10000000-0000-0000-0000-000000000013', 'صعدة', 'Saada Governorate', NULL, 16.9402, 43.7639, 13, true),
    ('10000000-0000-0000-0000-000000000014', 'المهرة', 'Al Mahrah Governorate', NULL, 16.2079, 52.1760, 14, true),
    ('10000000-0000-0000-0000-000000000015', 'عمران', 'Amran Governorate', NULL, 15.6594, 43.9439, 15, true),
    ('10000000-0000-0000-0000-000000000016', 'حجة', 'Hajjah Governorate', NULL, 15.6942, 43.6021, 16, true),
    ('10000000-0000-0000-0000-000000000017', 'البيضاء', 'Al Bayda Governorate', NULL, 13.9852, 45.5727, 17, true),
    ('10000000-0000-0000-0000-000000000018', 'الضالع', 'Ad Dali Governorate', NULL, 13.6957, 44.7314, 18, true),
    ('10000000-0000-0000-0000-000000000019', 'ريمة', 'Raymah Governorate', NULL, 14.6289, 43.7128, 19, true),
    ('10000000-0000-0000-0000-000000000020', 'المحويت', 'Al Mahwit Governorate', NULL, 15.4701, 43.5449, 20, true),
    ('10000000-0000-0000-0000-000000000021', 'سقطرى', 'Socotra Governorate', NULL, 12.6500, 54.0167, 21, true),
    ('10000000-0000-0000-0000-000000000022', 'الجوف', 'Al Jawf Governorate', NULL, 16.1404, 44.9609, 22, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_en = EXCLUDED.name_en,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- More Sanaa Capital districts (matching the app's district picker).
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000009', 'عصر', 'Asr', '10000000-0000-0000-0000-000000000001', 15.3350, 44.2000, 9, true),
    ('20000000-0000-0000-0000-000000000010', 'الحصبة', 'Al Hasabah', '10000000-0000-0000-0000-000000000001', 15.3300, 44.1900, 10, true),
    ('20000000-0000-0000-0000-000000000011', 'مذبح', 'Mathbah', '10000000-0000-0000-0000-000000000001', 15.3800, 44.1700, 11, true),
    ('20000000-0000-0000-0000-000000000012', 'الروضة', 'Al Rawdah', '10000000-0000-0000-0000-000000000001', 15.3500, 44.2200, 12, true),
    ('20000000-0000-0000-0000-000000000013', 'نقم', 'Nuqum', '10000000-0000-0000-0000-000000000001', 15.3100, 44.2300, 13, true),
    ('20000000-0000-0000-0000-000000000014', 'شميلة', 'Shamaila', '10000000-0000-0000-0000-000000000001', 15.3000, 44.2100, 14, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Sanaa Governorate districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000015', 'بني مطر', 'Bani Matar', '10000000-0000-0000-0000-000000000004', 15.2500, 44.2300, 1, true),
    ('20000000-0000-0000-0000-000000000016', 'سنحان', 'Sanhan', '10000000-0000-0000-0000-000000000004', 15.1700, 44.3000, 2, true),
    ('20000000-0000-0000-0000-000000000017', 'همدان', 'Hamdan', '10000000-0000-0000-0000-000000000004', 15.3000, 44.4000, 3, true),
    ('20000000-0000-0000-0000-000000000018', 'بني حشيش', 'Bani Hashish', '10000000-0000-0000-0000-000000000004', 15.2500, 44.5000, 4, true),
    ('20000000-0000-0000-0000-000000000019', 'بلاد الروس', 'Bilad Ar Rus', '10000000-0000-0000-0000-000000000004', 15.3000, 44.5500, 5, true),
    ('20000000-0000-0000-0000-000000000020', 'أرحب', 'Arhab', '10000000-0000-0000-0000-000000000004', 15.4500, 44.4000, 6, true),
    ('20000000-0000-0000-0000-000000000021', 'خولان', 'Khawlan', '10000000-0000-0000-0000-000000000004', 15.3500, 44.7000, 7, true),
    ('20000000-0000-0000-0000-000000000022', 'الحيمة الداخلية', 'Al Haymah Al Dakhiliyah', '10000000-0000-0000-0000-000000000004', 15.1500, 43.9500, 8, true),
    ('20000000-0000-0000-0000-000000000023', 'الحيمة الخارجية', 'Al Haymah Al Kharijiyah', '10000000-0000-0000-0000-000000000004', 15.1000, 43.8500, 9, true),
    ('20000000-0000-0000-0000-000000000024', 'مناخة', 'Manakhah', '10000000-0000-0000-0000-000000000004', 15.1000, 43.9800, 10, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Aden districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000025', 'المعلا', 'Al Mafla', '10000000-0000-0000-0000-000000000002', 12.7850, 45.0350, 1, true),
    ('20000000-0000-0000-0000-000000000026', 'كريتر', 'Crater', '10000000-0000-0000-0000-000000000002', 12.7800, 45.0300, 2, true),
    ('20000000-0000-0000-0000-000000000027', 'خور مكسر', 'Khormaksar', '10000000-0000-0000-0000-000000000002', 12.7500, 45.0300, 3, true),
    ('20000000-0000-0000-0000-000000000028', 'المنصورة', 'Al Mansoura', '10000000-0000-0000-0000-000000000002', 12.7900, 45.0000, 4, true),
    ('20000000-0000-0000-0000-000000000029', 'دار سعد', 'Dar Sad', '10000000-0000-0000-0000-000000000002', 12.8100, 44.9900, 5, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Taiz districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000030', 'القاهرة', 'Al Qahirah', '10000000-0000-0000-0000-000000000003', 13.5800, 44.0200, 1, true),
    ('20000000-0000-0000-0000-000000000031', 'المظفر', 'Al Muzaffar', '10000000-0000-0000-0000-000000000003', 13.5650, 44.0100, 2, true),
    ('20000000-0000-0000-0000-000000000032', 'السلام', 'Al Salam', '10000000-0000-0000-0000-000000000003', 13.5900, 44.0000, 3, true),
    ('20000000-0000-0000-0000-000000000033', 'حيفان', 'Hayfan', '10000000-0000-0000-0000-000000000003', 13.4500, 44.0500, 4, true),
    ('20000000-0000-0000-0000-000000000034', 'المخا', 'Al Mokha', '10000000-0000-0000-0000-000000000003', 13.3200, 43.2500, 5, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Hadramaut districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000035', 'المكلا', 'Al Mukalla', '10000000-0000-0000-0000-000000000005', 14.5400, 49.1300, 1, true),
    ('20000000-0000-0000-0000-000000000036', 'سيئون', 'Seiyun', '10000000-0000-0000-0000-000000000005', 16.0500, 48.9900, 2, true),
    ('20000000-0000-0000-0000-000000000037', 'تريم', 'Tarim', '10000000-0000-0000-0000-000000000005', 16.0560, 48.9960, 3, true),
    ('20000000-0000-0000-0000-000000000038', 'شبام', 'Shibam', '10000000-0000-0000-0000-000000000005', 16.0200, 48.9900, 4, true),
    ('20000000-0000-0000-0000-000000000039', 'سيحوت', 'Sayhut', '10000000-0000-0000-0000-000000000005', 15.9000, 52.2000, 5, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Ibb districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000040', 'إب', 'Ibb', '10000000-0000-0000-0000-000000000006', 14.0050, 44.1650, 1, true),
    ('20000000-0000-0000-0000-000000000041', 'يريم', 'Yarim', '10000000-0000-0000-0000-000000000006', 13.9800, 44.8300, 2, true),
    ('20000000-0000-0000-0000-000000000042', 'دمت', 'Dhamt', '10000000-0000-0000-0000-000000000006', 13.9000, 44.4000, 3, true),
    ('20000000-0000-0000-0000-000000000043', 'السبرة', 'As Sabrah', '10000000-0000-0000-0000-000000000006', 13.9500, 44.1000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Al Hudaydah districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000044', 'الحديدة', 'Al Hudaydah', '10000000-0000-0000-0000-000000000007', 14.7978, 42.9545, 1, true),
    ('20000000-0000-0000-0000-000000000045', 'المنصورية', 'Al Mansuriyah', '10000000-0000-0000-0000-000000000007', 14.7000, 42.9500, 2, true),
    ('20000000-0000-0000-0000-000000000046', 'الزيدية', 'Al Zaydiyah', '10000000-0000-0000-0000-000000000007', 15.1500, 43.1000, 3, true),
    ('20000000-0000-0000-0000-000000000047', 'باجل', 'Bajil', '10000000-0000-0000-0000-000000000007', 15.0000, 43.0000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Marib districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000048', 'مأرب', 'Marib', '10000000-0000-0000-0000-000000000008', 15.4624, 45.3258, 1, true),
    ('20000000-0000-0000-0000-000000000049', 'صرواح', 'Sawa', '10000000-0000-0000-0000-000000000008', 15.5500, 45.1500, 2, true),
    ('20000000-0000-0000-0000-000000000050', 'العبدية', 'Al Abdiyah', '10000000-0000-0000-0000-000000000008', 14.9500, 45.6000, 3, true),
    ('20000000-0000-0000-0000-000000000051', 'حريب', 'Harib', '10000000-0000-0000-0000-000000000008', 15.2000, 46.0000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Dhamar districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000052', 'ذمار', 'Dhamar', '10000000-0000-0000-0000-000000000009', 14.5427, 44.4051, 1, true),
    ('20000000-0000-0000-0000-000000000053', 'ردا', 'Rewa', '10000000-0000-0000-0000-000000000009', 14.6000, 44.7000, 2, true),
    ('20000000-0000-0000-0000-000000000054', 'وصاب', 'Wasab', '10000000-0000-0000-0000-000000000009', 14.4000, 43.9000, 3, true),
    ('20000000-0000-0000-0000-000000000055', 'عنس', 'Anas', '10000000-0000-0000-0000-000000000009', 14.5000, 44.5000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Shabwah districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000056', 'عتق', 'Ataq', '10000000-0000-0000-0000-000000000010', 14.5377, 46.8319, 1, true),
    ('20000000-0000-0000-0000-000000000057', 'بيحان', 'Bayhan', '10000000-0000-0000-0000-000000000010', 14.7500, 45.9000, 2, true),
    ('20000000-0000-0000-0000-000000000058', 'نجمان', 'Najman', '10000000-0000-0000-0000-000000000010', 14.3000, 46.2000, 3, true),
    ('20000000-0000-0000-0000-000000000059', 'المرفأ', 'Al Marfa', '10000000-0000-0000-0000-000000000010', 13.9500, 47.0000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Lahij districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000060', 'لحج', 'Lahij', '10000000-0000-0000-0000-000000000011', 13.0583, 44.8828, 1, true),
    ('20000000-0000-0000-0000-000000000061', 'الحوطة', 'Al Huta', '10000000-0000-0000-0000-000000000011', 13.0500, 44.9000, 2, true),
    ('20000000-0000-0000-0000-000000000062', 'تبن', 'Tuban', '10000000-0000-0000-0000-000000000011', 12.9500, 45.0000, 3, true),
    ('20000000-0000-0000-0000-000000000063', 'ردفان', 'Radfan', '10000000-0000-0000-0000-000000000011', 13.3000, 45.0000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Abyan districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000064', 'زنجبار', 'Zinjibar', '10000000-0000-0000-0000-000000000012', 13.1287, 45.3805, 1, true),
    ('20000000-0000-0000-0000-000000000065', 'جعار', 'Jaar', '10000000-0000-0000-0000-000000000012', 13.1330, 45.3600, 2, true),
    ('20000000-0000-0000-0000-000000000066', 'شقرة', 'Shuqra', '10000000-0000-0000-0000-000000000012', 13.4000, 45.6500, 3, true),
    ('20000000-0000-0000-0000-000000000067', 'لودر', 'Lawdar', '10000000-0000-0000-0000-000000000012', 13.9000, 45.8500, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Saada districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000068', 'صعدة', 'Saada', '10000000-0000-0000-0000-000000000013', 16.9402, 43.7639, 1, true),
    ('20000000-0000-0000-0000-000000000069', 'رزح', 'Razih', '10000000-0000-0000-0000-000000000013', 16.9000, 43.3000, 2, true),
    ('20000000-0000-0000-0000-000000000070', 'ساغر', 'Saghir', '10000000-0000-0000-0000-000000000013', 17.1500, 43.9000, 3, true),
    ('20000000-0000-0000-0000-000000000071', 'باقم', 'Baqim', '10000000-0000-0000-0000-000000000013', 17.2500, 43.4000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Al Mahrah districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000072', 'الغيظة', 'Al Ghaydah', '10000000-0000-0000-0000-000000000014', 16.2079, 52.1760, 1, true),
    ('20000000-0000-0000-0000-000000000073', 'حوف', 'Hawf', '10000000-0000-0000-0000-000000000014', 16.0000, 52.8000, 2, true),
    ('20000000-0000-0000-0000-000000000074', 'مسارة', 'Masarah', '10000000-0000-0000-0000-000000000014', 16.5000, 51.5000, 3, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Amran districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000075', 'عمران', 'Amran', '10000000-0000-0000-0000-000000000015', 15.6594, 43.9439, 1, true),
    ('20000000-0000-0000-0000-000000000076', 'حوث', 'Hut', '10000000-0000-0000-0000-000000000015', 15.7000, 43.6000, 2, true),
    ('20000000-0000-0000-0000-000000000077', 'السودان', 'As Sudan', '10000000-0000-0000-0000-000000000015', 15.5000, 44.0000, 3, true),
    ('20000000-0000-0000-0000-000000000078', 'بني العوام', 'Bani Al Awam', '10000000-0000-0000-0000-000000000015', 15.5500, 43.8500, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Hajjah districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000079', 'حجة', 'Hajjah', '10000000-0000-0000-0000-000000000016', 15.6942, 43.6021, 1, true),
    ('20000000-0000-0000-0000-000000000080', 'مستبا', 'Mustaba', '10000000-0000-0000-0000-000000000016', 16.1000, 43.4000, 2, true),
    ('20000000-0000-0000-0000-000000000081', 'أحور', 'Ahor', '10000000-0000-0000-0000-000000000016', 15.9500, 43.2000, 3, true),
    ('20000000-0000-0000-0000-000000000082', 'كسمه', 'Kusmah', '10000000-0000-0000-0000-000000000016', 15.8000, 43.3000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Al Bayda districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000083', 'البيضاء', 'Al Bayda', '10000000-0000-0000-0000-000000000017', 13.9852, 45.5727, 1, true),
    ('20000000-0000-0000-0000-000000000084', 'رداع', 'Radaa', '10000000-0000-0000-0000-000000000017', 14.0500, 45.5000, 2, true),
    ('20000000-0000-0000-0000-000000000085', 'القريشية', 'Al Quraishiyah', '10000000-0000-0000-0000-000000000017', 13.9000, 45.4000, 3, true),
    ('20000000-0000-0000-0000-000000000086', 'السوما', 'As Sumah', '10000000-0000-0000-0000-000000000017', 14.1000, 45.7000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Ad Dali districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000087', 'الضالع', 'Ad Dali', '10000000-0000-0000-0000-000000000018', 13.6957, 44.7314, 1, true),
    ('20000000-0000-0000-0000-000000000088', 'قعطبة', 'Qaatabah', '10000000-0000-0000-0000-000000000018', 13.6000, 44.3000, 2, true),
    ('20000000-0000-0000-0000-000000000089', 'الشارع', 'Ash Shariah', '10000000-0000-0000-0000-000000000018', 13.8000, 44.6000, 3, true),
    ('20000000-0000-0000-0000-000000000090', 'حتوم', 'Hutum', '10000000-0000-0000-0000-000000000018', 13.6500, 44.5000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Raymah districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000091', 'الجبين', 'Al Jabin', '10000000-0000-0000-0000-000000000019', 14.6289, 43.7128, 1, true),
    ('20000000-0000-0000-0000-000000000092', 'السلف', 'As Salaf', '10000000-0000-0000-0000-000000000019', 14.7000, 43.6000, 2, true),
    ('20000000-0000-0000-0000-000000000093', 'كعام', 'Kaam', '10000000-0000-0000-0000-000000000019', 14.5500, 43.8000, 3, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Al Mahwit districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000094', 'المحويت', 'Al Mahwit', '10000000-0000-0000-0000-000000000020', 15.4701, 43.5449, 1, true),
    ('20000000-0000-0000-0000-000000000095', 'الطويلة', 'At Tawilah', '10000000-0000-0000-0000-000000000020', 15.5000, 43.4000, 2, true),
    ('20000000-0000-0000-0000-000000000096', 'حفاش', 'Hafash', '10000000-0000-0000-0000-000000000020', 15.4000, 43.5000, 3, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Socotra districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000097', 'حديبو', 'Hadibo', '10000000-0000-0000-0000-000000000021', 12.6500, 54.0167, 1, true),
    ('20000000-0000-0000-0000-000000000098', 'قلنسية', 'Qalansiyah', '10000000-0000-0000-0000-000000000021', 12.7000, 53.5000, 2, true),
    ('20000000-0000-0000-0000-000000000099', 'موري', 'Mori', '10000000-0000-0000-0000-000000000021', 12.5500, 53.9000, 3, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- Al Jawf districts.
INSERT INTO public.locations (id, name_ar, name_en, parent_id, latitude, longitude, sort_order, is_active)
VALUES
    ('20000000-0000-0000-0000-000000000100', 'الجوف', 'Al Jawf', '10000000-0000-0000-0000-000000000022', 16.1404, 44.9609, 1, true),
    ('20000000-0000-0000-0000-000000000101', 'الحزم', 'Al Hazm', '10000000-0000-0000-0000-000000000022', 16.1500, 44.8000, 2, true),
    ('20000000-0000-0000-0000-000000000102', 'برط', 'Bart', '10000000-0000-0000-0000-000000000022', 16.4000, 44.7000, 3, true),
    ('20000000-0000-0000-0000-000000000103', 'الغاط', 'Al Ghat', '10000000-0000-0000-0000-000000000022', 15.9000, 44.4000, 4, true)
ON CONFLICT (id) DO UPDATE SET
    name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
    parent_id = EXCLUDED.parent_id, latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude, sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

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

