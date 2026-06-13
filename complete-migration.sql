-- ==========================================
-- MzimbaEduTrack Complete Database Migration
-- Creates all required tables, columns, functions, indexes, and constraints
-- ==========================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Create admins table
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create zones table
CREATE TABLE IF NOT EXISTS zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name VARCHAR(100) NOT NULL UNIQUE,
    zone_password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- 3. Create schools table
CREATE TABLE IF NOT EXISTS schools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_id UUID NOT NULL REFERENCES zones(id) ON DELETE RESTRICT,
    school_name VARCHAR(150) NOT NULL,
    school_code VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT unique_school_per_zone UNIQUE (zone_id, school_name)
);

-- 4. Create learners table
CREATE TABLE IF NOT EXISTS learners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_id UUID NOT NULL REFERENCES zones(id) ON DELETE RESTRICT,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE RESTRICT,
    full_name VARCHAR(255) NOT NULL,
    lin VARCHAR(16) NOT NULL,
    sex CHAR(1) CHECK (sex IN ('M', 'F')),
    class VARCHAR(60) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT unique_learner_lin UNIQUE (lin)
);

-- 5. Create results table
CREATE TABLE IF NOT EXISTS results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    learner_id UUID NOT NULL REFERENCES learners(id) ON DELETE CASCADE,
    zone_id UUID NOT NULL REFERENCES zones(id) ON DELETE RESTRICT,
    school_id UUID NOT NULL REFERENCES schools(id) ON DELETE RESTRICT,
    year INTEGER NOT NULL CHECK (year BETWEEN 2026 AND 2080),
    term INTEGER NOT NULL CHECK (term BETWEEN 1 AND 3),
    class VARCHAR(60) NOT NULL,
    aggregate_marks NUMERIC(6, 2) DEFAULT 0.00,
    overall_percentage NUMERIC(5, 2) DEFAULT 0.00,
    overall_position VARCHAR(50) DEFAULT 'N/A',
    overall_letter_grade VARCHAR(2) DEFAULT 'F',
    overall_grade_level VARCHAR(60),
    subjects_written INTEGER DEFAULT 0,
    subjects_passed INTEGER DEFAULT 0,
    subjects_failed INTEGER DEFAULT 0,
    overall_comment TEXT DEFAULT '',
    subject_teacher_comment TEXT DEFAULT '',
    head_teacher_comment TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    CONSTRAINT unique_learner_year_term UNIQUE (learner_id, year, term)
);

-- 6. Create result_subjects table
CREATE TABLE IF NOT EXISTS result_subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    result_id UUID NOT NULL REFERENCES results(id) ON DELETE CASCADE,
    subject_name VARCHAR(100) NOT NULL,
    exam_mark NUMERIC(5, 2) NOT NULL CHECK (exam_mark BETWEEN 0 AND 100),
    grade VARCHAR(2) NOT NULL,
    remarks TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_result_subject UNIQUE (result_id, subject_name)
);

-- 7. Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES admins(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(100),
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Create indexes
CREATE INDEX IF NOT EXISTS idx_schools_zone ON schools(zone_id);
CREATE INDEX IF NOT EXISTS idx_schools_not_deleted ON schools(id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_learners_school ON learners(school_id);
CREATE INDEX IF NOT EXISTS idx_learners_lin ON learners(lin);
CREATE INDEX IF NOT EXISTS idx_learners_not_deleted ON learners(id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_results_learner ON results(learner_id);
CREATE INDEX IF NOT EXISTS idx_results_year_term ON results(year, term);
CREATE INDEX IF NOT EXISTS idx_results_not_deleted ON results(id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_result_subjects_result ON result_subjects(result_id);

-- 9. Create calculate_grade function
CREATE OR REPLACE FUNCTION calculate_grade(mark NUMERIC)
RETURNS VARCHAR(2) LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
    IF mark >= 80 THEN RETURN 'A';
    ELSIF mark >= 70 THEN RETURN 'B';
    ELSIF mark >= 60 THEN RETURN 'C';
    ELSIF mark >= 50 THEN RETURN 'D';
    ELSE RETURN 'F';
    END IF;
END;
$$;

-- 10. Create update_result_aggregates trigger function
CREATE OR REPLACE FUNCTION update_result_aggregates()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    total_marks NUMERIC;
    subject_count INTEGER;
    passed_count INTEGER;
    failed_count INTEGER;
BEGIN
    SELECT 
        SUM(exam_mark),
        COUNT(*),
        SUM(CASE WHEN calculate_grade(exam_mark) IN ('A', 'B', 'C', 'D') THEN 1 ELSE 0 END),
        SUM(CASE WHEN calculate_grade(exam_mark) = 'F' THEN 1 ELSE 0 END)
    INTO total_marks, subject_count, passed_count, failed_count
    FROM result_subjects
    WHERE result_id = NEW.result_id;

    UPDATE results
    SET 
        aggregate_marks = COALESCE(total_marks, 0),
        overall_percentage = CASE 
            WHEN subject_count > 0 THEN ROUND((COALESCE(total_marks, 0) / (subject_count * 100)) * 100, 2)
            ELSE 0 
        END,
        overall_letter_grade = CASE 
            WHEN subject_count > 0 THEN calculate_grade(ROUND((COALESCE(total_marks, 0) / (subject_count * 100)) * 100))
            ELSE 'F' 
        END,
        subjects_written = COALESCE(subject_count, 0),
        subjects_passed = COALESCE(passed_count, 0),
        subjects_failed = COALESCE(failed_count, 0),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.result_id;

    RETURN NEW;
END;
$$;

-- 11. Create trigger for result_subjects
DROP TRIGGER IF EXISTS trigger_update_result_aggregates ON result_subjects;
CREATE TRIGGER trigger_update_result_aggregates
AFTER INSERT OR UPDATE OR DELETE ON result_subjects
FOR EACH ROW EXECUTE FUNCTION update_result_aggregates();

-- 12. Create validate_zone_password RPC function
CREATE OR REPLACE FUNCTION validate_zone_password(zone_name TEXT, password TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    stored_password TEXT;
BEGIN
    SELECT zone_password INTO stored_password
    FROM zones
    WHERE zones.zone_name = validate_zone_password.zone_name 
      AND zones.is_deleted = FALSE
    LIMIT 1;

    RETURN stored_password = validate_zone_password.password;
END;
$$;

-- 13. Create fetch_report_card RPC function
CREATE OR REPLACE FUNCTION fetch_report_card(
    p_zone_name TEXT,
    p_school_id UUID,
    p_class TEXT,
    p_lin TEXT,
    p_year INTEGER,
    p_term INTEGER
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    report jsonb;
    total_learners INTEGER;
    dynamic_position INTEGER;
BEGIN
    -- Calculate total number of learners in same school, class, year, term
    SELECT COUNT(*) INTO total_learners
    FROM results r2
    JOIN learners l2 ON l2.id = r2.learner_id
    WHERE r2.school_id = p_school_id
        AND r2.class = p_class
        AND r2.year = p_year
        AND r2.term = p_term
        AND l2.is_deleted = FALSE
        AND r2.is_deleted = FALSE;

    -- First get the base report
    WITH report_data AS (
        SELECT
            s.school_name,
            z.zone_name,
            l.full_name,
            l.lin,
            r.class,
            r.year,
            r.term,
            r.aggregate_marks,
            r.overall_percentage,
            r.overall_position,
            r.overall_letter_grade,
            r.overall_grade_level,
            r.subjects_written,
            r.subjects_passed,
            r.subjects_failed,
            r.overall_comment,
            r.subject_teacher_comment,
            r.head_teacher_comment,
            r.id AS result_id
        FROM zones z
        JOIN schools s ON s.zone_id = z.id
        JOIN learners l ON l.school_id = s.id
        JOIN results r ON r.learner_id = l.id
        WHERE z.zone_name = p_zone_name
            AND s.id = p_school_id
            AND l.lin = p_lin
            AND r.class = p_class
            AND r.year = p_year
            AND r.term = p_term
            AND z.is_deleted = FALSE
            AND s.is_deleted = FALSE
            AND l.is_deleted = FALSE
            AND r.is_deleted = FALSE
        LIMIT 1
    )
    SELECT
        -- Calculate dynamic position if needed
        CASE
            WHEN rd.overall_position IS NOT NULL THEN rd.overall_position::INTEGER
            ELSE (
                SELECT COUNT(*) + 1
                FROM results r3
                WHERE r3.school_id = p_school_id
                    AND r3.class = p_class
                    AND r3.year = p_year
                    AND r3.term = p_term
                    AND r3.is_deleted = FALSE
                    AND r3.aggregate_marks > rd.aggregate_marks
            )
        END
    INTO dynamic_position
    FROM report_data rd;

    -- Build final report
    SELECT jsonb_build_object(
        'school', rd.school_name,
        'zone', rd.zone_name,
        'learnerName', rd.full_name,
        'lin', rd.lin,
        'class', rd.class,
        'year', rd.year,
        'term', rd.term,
        'aggregateMarks', rd.aggregate_marks,
        'overallPercentage', rd.overall_percentage,
        'overallPosition', COALESCE(rd.overall_position, dynamic_position::TEXT),
        'totalLearners', total_learners,
        'overallLetterGrade', rd.overall_letter_grade,
        'overallGradeLevel', rd.overall_grade_level,
        'subjectsWritten', rd.subjects_written,
        'subjectsPassed', rd.subjects_passed,
        'subjectsFailed', rd.subjects_failed,
        'overallComment', rd.overall_comment,
        'subjectTeacherComment', rd.subject_teacher_comment,
        'headTeacherComment', rd.head_teacher_comment,
        'subjectScores', (
            SELECT jsonb_object_agg(subject_name, jsonb_build_object(
                'exam', exam_mark,
                'total', exam_mark,
                'grade', grade,
                'remarks', COALESCE(remarks, '')
            ))
            FROM result_subjects
            WHERE result_id = rd.result_id
        )
    )
    INTO report
    FROM report_data rd;

    RETURN report;
END;
$$;

-- 14. Enable Row Level Security (RLS) on all tables
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE learners ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE result_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 15. Create RLS policies

-- Zones policies
DROP POLICY IF EXISTS "Allow public select zones" ON zones;
CREATE POLICY "Allow public select zones" ON zones
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow authenticated admins all zones" ON zones;
CREATE POLICY "Allow authenticated admins all zones" ON zones
    FOR ALL USING (auth.role() = 'authenticated');

-- Schools policies
DROP POLICY IF EXISTS "Allow public select schools" ON schools;
CREATE POLICY "Allow public select schools" ON schools
    FOR SELECT USING (is_deleted = false);
DROP POLICY IF EXISTS "Allow authenticated admins all schools" ON schools;
CREATE POLICY "Allow authenticated admins all schools" ON schools
    FOR ALL USING (auth.role() = 'authenticated');

-- Learners policies
DROP POLICY IF EXISTS "Allow public select learners" ON learners;
CREATE POLICY "Allow public select learners" ON learners
    FOR SELECT USING (is_deleted = false);
DROP POLICY IF EXISTS "Allow authenticated admins all learners" ON learners;
CREATE POLICY "Allow authenticated admins all learners" ON learners
    FOR ALL USING (auth.role() = 'authenticated');

-- Results policies
DROP POLICY IF EXISTS "Allow public select results" ON results;
CREATE POLICY "Allow public select results" ON results
    FOR SELECT USING (is_deleted = false);
DROP POLICY IF EXISTS "Allow authenticated admins all results" ON results;
CREATE POLICY "Allow authenticated admins all results" ON results
    FOR ALL USING (auth.role() = 'authenticated');

-- Result subjects policies
DROP POLICY IF EXISTS "Allow public select result subjects" ON result_subjects;
CREATE POLICY "Allow public select result subjects" ON result_subjects
    FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow authenticated admins all result subjects" ON result_subjects;
CREATE POLICY "Allow authenticated admins all result subjects" ON result_subjects
    FOR ALL USING (auth.role() = 'authenticated');

-- Audit logs policies
DROP POLICY IF EXISTS "Allow authenticated admins select audit logs" ON audit_logs;
CREATE POLICY "Allow authenticated admins select audit logs" ON audit_logs
    FOR SELECT USING (auth.role() = 'authenticated');
DROP POLICY IF EXISTS "Allow authenticated admins insert audit logs" ON audit_logs;
CREATE POLICY "Allow authenticated admins insert audit logs" ON audit_logs
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 16. Insert default zones
INSERT INTO zones (zone_name, zone_password)
VALUES
    ('CHASATO', 'CHASATO001'),
    ('CHIKANGAWA', 'CHIKANGAWA002'),
    ('CHIZUNGU', 'CHIZUNGU003'),
    ('EDINGENI', 'EDINGENI004'),
    ('EMFENI', 'EMFENI005'),
    ('ENDINDENI', 'ENDINDENI006'),
    ('EPHANGWENI', 'EPHANGWENI007'),
    ('KABENA', 'KABENA008'),
    ('KABUWA', 'KABUWA009'),
    ('KANJUCHI', 'KANJUCHI010'),
    ('KAPHUTA', 'KAPHUTA011'),
    ('KAPOLI', 'KAPOLI012'),
    ('KATETE', 'KATETE013'),
    ('KAVUULA', 'KAVUULA014'),
    ('KAZINGILIRA', 'KAZINGILIRA015'),
    ('LUVIRI', 'LUVIRI016'),
    ('LUWEREZI', 'LUWEREZI017'),
    ('MABIRI', 'MABIRI018'),
    ('MACHELECHETE', 'MACHELECHETE019'),
    ('MANYAMULA', 'MANYAMULA020'),
    ('MHARAUNDA', 'MHARAUNDA021'),
    ('MPHONGO', 'MPHONGO022'),
    ('MZOMA', 'MZOMA023'),
    ('UNYOLO', 'UNYOLO024'),
    ('VAZALA', 'VAZALA025'),
    ('VIBANGALALA', 'VIBANGALALA026')
ON CONFLICT (zone_name) DO NOTHING;

-- ==========================================
-- Migration Complete!
-- ==========================================
