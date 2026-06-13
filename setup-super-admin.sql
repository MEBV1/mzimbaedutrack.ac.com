-- Insert a default super admin (you should change the email and add to your own
-- Remember to also create this user in Supabase Auth with the same email
INSERT INTO admins (email, full_name, role)
VALUES ('superadmin@example.com', 'Super Admin', 'super_admin')
ON CONFLICT (email) DO NOTHING;
