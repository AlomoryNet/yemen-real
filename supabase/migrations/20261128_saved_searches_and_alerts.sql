-- Saved searches and in-app alerts for newly published matching listings.
-- Rerunnable: safe to apply more than once.

-- ==============================================================================
-- Saved searches
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

-- ==============================================================================
-- Alert generation
-- ==============================================================================
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
