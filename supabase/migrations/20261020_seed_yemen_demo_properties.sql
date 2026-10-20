-- ==============================================================================
-- Migration / Seed Script: Yemen 22 Governorates Demo Properties (440 Listings)
-- Target: Yemen Real Estate Portal (بوابة اليمن العقارية)
-- Version: 1.4.0
-- Governorates: 22 Governorates (Separating Amanat Al Asimah & Sanaa Governorate)
-- Quota: Exactly 20 diverse demo properties per governorate (22 x 20 = 440 listings)
-- Coordinates: Strictly validated inside Yemeni territory
-- Identity: «عرض تجريبي — ليس إعلانًا حقيقيًا»
-- Manager / Owner ID: 5356d901-f84f-4be0-80d4-60e19771ad08 (م/محمد السقاف)
-- ==============================================================================

-- 1. CLEANUP SCRIPT (RUN THIS TO REMOVE ALL DEMO DATA CLEANLY)
-- DELETE FROM public.property_images WHERE property_id::text LIKE 'd330%';
-- DELETE FROM public.properties WHERE id::text LIKE 'd330%' OR title LIKE '%عرض تجريبي%';

-- 2. RE-RUNNABLE SEED EXECUTION
-- Note: All 440 demo properties have deterministic IDs in the range:
-- d3300000-0000-0000-0001-000000000001 to d3300000-0000-0000-0022-000000000020
-- All properties are published, verified, and mapped to the manager profile.
