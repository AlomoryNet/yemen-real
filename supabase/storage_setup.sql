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
