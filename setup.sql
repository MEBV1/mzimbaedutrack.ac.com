-- ==========================================
-- MZIMBA EDUTRACK SETUP SCRIPT
-- ==========================================

-- ==========================================
-- STEP 1: INSERT ZONES WITH DEFAULT PASSWORDS
-- ==========================================
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
-- VERIFICATION QUERY
-- ==========================================
SELECT 
    'Setup Complete' AS status,
    COUNT(*) AS zones_created
FROM zones;
