-- Property viewing appointments for rental requests.
-- Rerunnable: safe to apply more than once.

ALTER TABLE public.rental_requests
    ADD COLUMN IF NOT EXISTS scheduled_visit_at TIMESTAMPTZ;

COMMENT ON COLUMN public.rental_requests.scheduled_visit_at IS
    'Confirmed or proposed property viewing appointment; distinct from the desired move-in date.';
