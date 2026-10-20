-- ==============================================================================
-- Migration: Enforce Admin-Only Approval for Properties
-- Date: 2026-10-20
-- Description: Strictly prevents regular users from approving their own properties
-- or modifying review metadata, while allowing sole admin approval.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.enforce_property_publishing_rules()
RETURNS TRIGGER AS $$
BEGIN
    -- If actor is admin or service_role, permit all valid status transitions
    IF public.is_admin(auth.uid()) OR auth.uid() IS NULL THEN
        RETURN NEW;
    END IF;

    -- Non-admin users cannot directly publish properties
    IF NEW.status = 'published' AND (OLD IS NULL OR OLD.status != 'published') THEN
        -- Safely force to pending review instead of allowing direct publishing
        NEW.status := 'pending';
    END IF;

    -- Non-admin users cannot alter review metadata
    IF OLD IS NOT NULL THEN
        NEW.reviewed_by := OLD.reviewed_by;
        NEW.reviewed_at := OLD.reviewed_at;
    ELSE
        NEW.reviewed_by := NULL;
        NEW.reviewed_at := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_enforce_property_publishing_rules ON public.properties;
CREATE TRIGGER trg_enforce_property_publishing_rules
BEFORE INSERT OR UPDATE ON public.properties
FOR EACH ROW EXECUTE FUNCTION public.enforce_property_publishing_rules();
