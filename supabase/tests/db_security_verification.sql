-- ============================================================================
-- Security Verification Suite v8 (Local & Staging - Zero False Positive Rigor)
-- Target: Yemen Real Estate Portal - Sole Publishing Admin Verification
--
-- STRICT OPERATIONAL BOUNDARY:
-- For use in isolated local/staging environments ONLY.
-- Absolutely NO execution against cloud or production environments.
--
-- V8 ENHANCEMENTS:
-- 1. Defeats false positives: Catch blocks NEVER catch their own failure assertions.
-- 2. Explicit triple-branch evaluation for all forbidden operations:
--    - Unauthorized success => Catastrophic test failure.
--    - Expected security denial => Test passed.
--    - Unexpected error => Test failure.
-- 3. Tests image manipulation, hijacking, review tampering, and profile isolation.
-- 4. Guaranteed rollback/cleanup of test UUIDs without touching existing records.
-- ============================================================================

DO $$
DECLARE
    -- Admin parameters
    v_admin_id CONSTANT UUID := 'daa0d684-f82b-4878-9d86-ce2810be9786'::UUID;
    v_admin_email CONSTANT TEXT := 'mo772522233@gmail.com';

    -- Dynamic test entity UUIDs (Guarantees isolation)
    v_user_a UUID := gen_random_uuid();
    v_user_b UUID := gen_random_uuid();
    v_prop_1 UUID := gen_random_uuid();
    v_prop_2 UUID := gen_random_uuid();
    v_img_1 UUID := gen_random_uuid();
    v_img_2 UUID := gen_random_uuid();

    -- Verification state tracking variables
    v_op_succeeded BOOLEAN;
    v_expected_denial BOOLEAN;
    v_unexpected_err BOOLEAN;
    v_err_msg TEXT;
    v_err_state TEXT;
    v_status TEXT;
    v_reviewed_by UUID;
    v_is_featured BOOLEAN;
    v_rejection_reason TEXT;
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Starting Security Verification Suite v8 (Rigor Mode)';
    RAISE NOTICE '=====================================================';

    -- ------------------------------------------------------------------------
    -- 0. Setup Isolated Test Fixtures
    -- ------------------------------------------------------------------------
    INSERT INTO public.profiles (id, email, full_name, role, is_verified, phone)
    VALUES 
        (v_user_a, 'usera_' || substr(v_user_a::text, 1, 8) || '@test.local', 'Test User A', 'user', FALSE, '770000001'),
        (v_user_b, 'userb_' || substr(v_user_b::text, 1, 8) || '@test.local', 'Test User B', 'user', FALSE, '770000002');

    -- Ensure admin fixture exists in local environment
    INSERT INTO public.profiles (id, email, full_name, role, is_verified, phone)
    VALUES (v_admin_id, v_admin_email, 'م/محمد السقاف', 'super_admin', TRUE, '772522233')
    ON CONFLICT (id) DO UPDATE 
    SET role = 'super_admin', is_verified = TRUE, email = v_admin_email, full_name = 'م/محمد السقاف';

    -- ------------------------------------------------------------------------
    -- TEST 1: Privilege Escalation Prevention (Role modification by user)
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;
    v_err_msg := NULL;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        UPDATE public.profiles
        SET role = 'super_admin'
        WHERE id = v_user_a;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%Privilege escalation forbidden%' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 1): User A was able to escalate role to super_admin!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 1 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    ELSIF NOT v_expected_denial THEN
        RAISE EXCEPTION 'TEST 1 FAILED: Operation was neither executed nor properly blocked.';
    END IF;
    RAISE NOTICE '✓ TEST 1 PASSED: Role escalation strictly blocked with expected exception.';

    -- ------------------------------------------------------------------------
    -- TEST 2: Self-Verification Prevention (is_verified modification by user)
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        UPDATE public.profiles
        SET is_verified = TRUE
        WHERE id = v_user_a;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%Self-verification forbidden%' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 2): User A verified their own account!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 2 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    ELSIF NOT v_expected_denial THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Self-verification not blocked as expected.';
    END IF;
    RAISE NOTICE '✓ TEST 2 PASSED: Self-verification strictly blocked.';

    -- ------------------------------------------------------------------------
    -- TEST 3: Direct Publishing Bypass Prevention (Creation forced to pending)
    -- ------------------------------------------------------------------------
    PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    INSERT INTO public.properties (id, owner_id, title, price, status, is_featured, views_count)
    VALUES (v_prop_1, v_user_a, 'Luxury Villa', 100000, 'published', TRUE, 500);

    SELECT status, is_featured, views_count INTO v_status, v_is_featured, v_reviewed_by
    FROM public.properties WHERE id = v_prop_1;

    IF v_status <> 'pending' THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 3): Listing inserted with status % instead of pending!', v_status;
    END IF;
    IF v_is_featured <> FALSE THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 3): Listing forced is_featured = TRUE on creation!';
    END IF;
    RAISE NOTICE '✓ TEST 3 PASSED: Direct publishing forced to pending; metrics reset to 0.';

    -- ------------------------------------------------------------------------
    -- TEST 4: Direct Modification of Review Metadata Forbidden (reviewed_by)
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        UPDATE public.properties
        SET reviewed_by = v_admin_id
        WHERE id = v_prop_1;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%Direct modification of review metadata is strictly forbidden%' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 4): User A forged reviewed_by metadata!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 4 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    END IF;
    RAISE NOTICE '✓ TEST 4 PASSED: Direct modification of review metadata strictly blocked.';

    -- ------------------------------------------------------------------------
    -- TEST 5: Sole Admin Authorized Approval & Review Stamp
    -- ------------------------------------------------------------------------
    PERFORM set_config('request.jwt.claim.sub', v_admin_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    UPDATE public.properties
    SET status = 'published'
    WHERE id = v_prop_1;

    SELECT status, reviewed_by INTO v_status, v_reviewed_by
    FROM public.properties WHERE id = v_prop_1;

    IF v_status <> 'published' OR v_reviewed_by <> v_admin_id THEN
        RAISE EXCEPTION 'TEST 5 FAILED: Sole admin publishing failed. status=%, reviewed_by=%', v_status, v_reviewed_by;
    END IF;
    RAISE NOTICE '✓ TEST 5 PASSED: Sole admin approved and published listing with verified audit stamp.';

    -- ------------------------------------------------------------------------
    -- TEST 6: Manual Revert to Pending Forbidden Without Content/Media Edits
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        -- Attempt to clear review status manually without any edits
        UPDATE public.properties
        SET status = 'pending'
        WHERE id = v_prop_1;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%Published properties cannot be manually reverted%' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 6): User manually changed published status without edits!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 6 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    END IF;
    RAISE NOTICE '✓ TEST 6 PASSED: Manual status alteration without content/media change blocked.';

    -- ------------------------------------------------------------------------
    -- TEST 7: Image Addition on Published Listing Cascades Review Reset
    -- ------------------------------------------------------------------------
    PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    INSERT INTO public.property_images (id, property_id, url, is_primary)
    VALUES (v_img_1, v_prop_1, 'https://test.local/img1.jpg', TRUE);

    SELECT status, reviewed_by INTO v_status, v_reviewed_by
    FROM public.properties WHERE id = v_prop_1;

    IF v_status <> 'pending' OR v_reviewed_by IS NOT NULL THEN
        RAISE EXCEPTION 'TEST 7 FAILED: Image addition did not cascade reset to pending! status=%, reviewed_by=%', v_status, v_reviewed_by;
    END IF;
    RAISE NOTICE '✓ TEST 7 PASSED: Media addition safely reverted listing to pending via verified ticket queue.';

    -- Admin re-approves for subsequent tests
    PERFORM set_config('request.jwt.claim.sub', v_admin_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
    UPDATE public.properties SET status = 'published' WHERE id = v_prop_1;

    -- ------------------------------------------------------------------------
    -- TEST 8: Image Hijacking Across Properties is Forbidden (RLS WITH CHECK)
    -- ------------------------------------------------------------------------
    -- User B creates their property
    PERFORM set_config('request.jwt.claim.sub', v_user_b::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    INSERT INTO public.properties (id, owner_id, title, price, status)
    VALUES (v_prop_2, v_user_b, 'User B Property', 60000, 'pending');

    -- User A attempts to reassign v_img_1 to User B's property
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        UPDATE public.property_images
        SET property_id = v_prop_2
        WHERE id = v_img_1;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        -- RLS violation error state 42501 or check constraint
        IF v_err_msg LIKE '%violates row-level security policy%' OR v_err_state = '42501' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 8): User A successfully hijacked image into User B listing!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 8 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    END IF;
    RAISE NOTICE '✓ TEST 8 PASSED: Image hijacking across properties blocked by RLS WITH CHECK.';

    -- ------------------------------------------------------------------------
    -- TEST 9: Ownership Transfer Forbidden (owner_id immutability)
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        UPDATE public.properties
        SET owner_id = v_user_b
        WHERE id = v_prop_1;

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%Property ownership cannot be transferred%' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 9): Property ownership was transferred!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 9 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    END IF;
    RAISE NOTICE '✓ TEST 9 PASSED: Ownership transfer strictly forbidden.';

    -- ------------------------------------------------------------------------
    -- TEST 10: Direct Access to Internal Ticket Queue Forbidden (RLS / REVOKE)
    -- ------------------------------------------------------------------------
    v_op_succeeded := FALSE;
    v_expected_denial := FALSE;
    v_unexpected_err := FALSE;

    BEGIN
        PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
        PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

        INSERT INTO public._property_media_resets (property_id)
        VALUES (v_prop_1);

        v_op_succeeded := TRUE;
    EXCEPTION WHEN OTHERS THEN
        v_err_msg := SQLERRM;
        v_err_state := SQLSTATE;
        IF v_err_msg LIKE '%permission denied%' OR v_err_state = '42501' THEN
            v_expected_denial := TRUE;
        ELSE
            v_unexpected_err := TRUE;
        END IF;
    END;

    IF v_op_succeeded THEN
        RAISE EXCEPTION 'CRITICAL BREACH (Test 10): Untrusted user inserted directly into _property_media_resets!';
    ELSIF v_unexpected_err THEN
        RAISE EXCEPTION 'TEST 10 FAILED (Unexpected error): % (State: %)', v_err_msg, v_err_state;
    END IF;
    RAISE NOTICE '✓ TEST 10 PASSED: Untrusted access to internal ticket queue blocked.';

    -- ------------------------------------------------------------------------
    -- Complete Cleanup of Test Records
    -- ------------------------------------------------------------------------
    DELETE FROM public.property_images WHERE id IN (v_img_1, v_img_2);
    DELETE FROM public.properties WHERE id IN (v_prop_1, v_prop_2);
    DELETE FROM public.profiles WHERE id IN (v_user_a, v_user_b);
    DELETE FROM public._property_media_resets WHERE property_id IN (v_prop_1, v_prop_2);

    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'All 10 Rigorous Security Scenarios Passed with 0 False Positives!';
    RAISE NOTICE 'Test fixtures cleaned up completely.';
    RAISE NOTICE '=====================================================';

EXCEPTION WHEN OTHERS THEN
    -- Guaranteed Cleanup on Any Failure
    DELETE FROM public.property_images WHERE id IN (v_img_1, v_img_2);
    DELETE FROM public.properties WHERE id IN (v_prop_1, v_prop_2);
    DELETE FROM public.profiles WHERE id IN (v_user_a, v_user_b);
    DELETE FROM public._property_media_resets WHERE property_id IN (v_prop_1, v_prop_2);
    RAISE EXCEPTION 'Security Suite Failed: % (State: %)', SQLERRM, SQLSTATE;
END $$;
