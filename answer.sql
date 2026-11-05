-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tbl TEXT,
    op TEXT,
    old_row JSONB,
    new_row JSONB,
    changed_by TEXT DEFAULT current_user,
    at TIMESTAMPTZ DEFAULT now()
);

-- Create reusable audit function
CREATE OR REPLACE FUNCTION audit()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (
        tbl, op, old_row, new_row
    )
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE
            WHEN TG_OP IN ('UPDATE', 'DELETE')
            THEN to_jsonb(OLD)
            ELSE NULL
        END,
        CASE
            WHEN TG_OP IN ('INSERT', 'UPDATE')
            THEN to_jsonb(NEW)
            ELSE NULL
        END
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Remove existing trigger if present
DROP TRIGGER IF EXISTS trg_audit ON students;

-- Create audit trigger
CREATE TRIGGER trg_audit
AFTER INSERT OR UPDATE OR DELETE
ON students
FOR EACH ROW
EXECUTE FUNCTION audit();

-- Verify trigger
SELECT
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'trg_audit';

-- Update a student
UPDATE students
SET name = 'Kofi M.'
WHERE id = 1;

-- Delete a student
DELETE FROM students
WHERE id = 3;

-- Inspect audit records
SELECT
    tbl,
    op,
    old_row->>'name' AS was,
    new_row->>'name' AS now,
    changed_by,
    at
FROM audit_log
ORDER BY at DESC;

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT REFERENCES categories(id)
);

-- Insert sample categories
INSERT INTO categories (name, parent_id)
VALUES
    ('Electronics', NULL),
    ('Computers', 1),
    ('Laptops', 2),
    ('Phones', 1);

-- Query the category hierarchy
WITH RECURSIVE tree AS (
    SELECT
        id,
        name,
        parent_id,
        0 AS depth
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.parent_id,
        t.depth + 1
    FROM categories c
    JOIN tree t ON c.parent_id = t.id
)
SELECT
    repeat('  ', depth) || name AS tree,
    depth
FROM tree
ORDER BY depth, id;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'app_read'
    ) THEN
        CREATE ROLE app_read NOLOGIN;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'app_write'
    ) THEN
        CREATE ROLE app_write NOLOGIN;
    END IF;
END
$$;

GRANT CONNECT ON DATABASE bootcamp
TO app_read, app_write;

GRANT USAGE ON SCHEMA public
TO app_read, app_write;

GRANT SELECT
ON ALL TABLES IN SCHEMA public
TO app_read;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO app_write;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO app_write;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'api'
    ) THEN
        CREATE USER api
        WITH LOGIN PASSWORD 'ChangeThis_StrongPassword123!';
    END IF;
END
$$;

GRANT app_write TO api;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO app_read;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO app_write;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO app_write;

SELECT
    rolname,
    rolsuper,
    rolcanlogin
FROM pg_roles
WHERE rolname IN ('app_read', 'app_write', 'api');

SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('app_read', 'app_write', 'api')
ORDER BY grantee, table_name;

SELECT * FROM audit_log;

SELECT tgname
FROM pg_trigger
WHERE tgrelid = 'students'::regclass
AND NOT tgisinternal;

WITH RECURSIVE tree AS (
    SELECT id, name, parent_id, 0 AS depth
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.id, c.name, c.parent_id, t.depth + 1
    FROM categories c
    JOIN tree t ON c.parent_id = t.id
)
SELECT repeat('  ', depth) || name AS category_tree
FROM tree
ORDER BY depth, id;

SELECT *
FROM flyway_schema_history
ORDER BY installed_rank;

SELECT
    has_database_privilege('api', 'bootcamp', 'CONNECT')
    AS can_connect,
    has_table_privilege('api', 'students', 'SELECT')
    AS can_read_students,
    has_table_privilege('api', 'students', 'INSERT')
    AS can_insert_students;
