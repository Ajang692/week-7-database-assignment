-- Verify that the core students table exists
DO $$
BEGIN
    IF to_regclass('public.students') IS NULL THEN
        RAISE EXCEPTION 'The students table does not exist';
    END IF;
END $$;
