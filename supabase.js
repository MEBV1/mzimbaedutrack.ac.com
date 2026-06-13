/**
 * MzimbaEduTrack Database Layer
 * Complete Supabase integration
 */

// List of all zones
const ZONE_NAMES = [
    'CHASATO', 'CHIKANGAWA', 'CHIZUNGU', 'EDINGENI', 'EMFENI', 'ENDINDENI',
    'EPHANGWENI', 'KABENA', 'KABUWA', 'KANJUCHI', 'KAPHUTA', 'KAPOLI',
    'KATETE', 'KAVUULA', 'KAZINGILIRA', 'LUVIRI', 'LUWEREZI', 'MABIRI',
    'MACHELECHETE', 'MANYAMULA', 'MHARAUNDA', 'MPHONGO', 'MZOMA', 'UNYOLO',
    'VAZALA', 'VIBANGALALA'
];

// List of all report subjects
const REPORT_SUBJECTS = [
    'English',
    'Chichewa',
    'Mathematics',
    'Primary Science',
    'Social and Economic Studies',
    'Arts/Life Skills'
];

// Supabase client instance
let supabaseClient = null;

// Initialize Supabase client
function initializeSupabaseClient() {
    if (supabaseClient) {
        return supabaseClient;
    }

    const config = Config.getSupabaseConfig();

    if (!config.url || !config.anonKey) {
        console.warn('Supabase configuration missing');
        return null;
    }

    const { createClient } = window.supabase || {};
    if (typeof createClient !== 'function') {
        console.error('Supabase library not loaded');
        return null;
    }

    supabaseClient = createClient(config.url, config.anonKey);
    console.log('✓ Supabase client initialized');

    // Initialize realtime
    if (typeof Realtime !== 'undefined' && config.enableRealtime) {
        Realtime.initialize(supabaseClient);
    }

    return supabaseClient;
}

// Calculate grade from mark
function calculateGrade(mark) {
    if (mark >= 80) return 'A';
    if (mark >= 70) return 'B';
    if (mark >= 60) return 'C';
    if (mark >= 50) return 'D';
    return 'F';
}

// Parse term string to number
function parseTerm(termString) {
    if (termString === 'Term One') return 1;
    if (termString === 'Term Two') return 2;
    if (termString === 'Term Three') return 3;
    const parsed = parseInt(termString, 10);
    if ([1, 2, 3].includes(parsed)) return parsed;
    return null;
}

// Main database operations
const EduTrackDB = {
    ZONE_NAMES,
    REPORT_SUBJECTS,

    async checkConnection() {
        const client = initializeSupabaseClient();
        if (!client) return false;

        try {
            const { error } = await client.from('zones').select('id').limit(1);
            return !error;
        } catch (err) {
            console.error('Connection check failed:', err);
            return false;
        }
    },

    async signInAdmin(email, password) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { data: authData, error: authError } = await client.auth.signInWithPassword({
            email,
            password
        });

        console.log('signInAdmin - authError:', authError);
        console.log('signInAdmin - authenticated user email:', authData?.user?.email);

        if (authError) {
            console.log('signInAdmin - throwing authError:', authError);
            throw authError;
        }

        const { data: adminData, error: adminError } = await client
            .from('admins')
            .select('*')
            .eq('email', email)
            .single();

        console.log('signInAdmin - admins table lookup result (adminData):', adminData);
        console.log('signInAdmin - adminError:', adminError);

        if (adminError && adminError.code !== 'PGRST116') {
            console.log('signInAdmin - throwing adminError:', adminError);
            throw adminError;
        }

        if (!adminData) {
            await client.auth.signOut();
            const err = new Error('Admin not authorized');
            console.log('signInAdmin - throwing error:', err);
            throw err;
        }

        return adminData;
    },

    async signOutAdmin() {
        const client = initializeSupabaseClient();
        if (client) {
            await client.auth.signOut();
        }
    },

    async getZones() {
        const client = initializeSupabaseClient();

        if (!client) {
            return ZONE_NAMES.map(name => ({ zone_name: name }));
        }

        try {
            const { data, error } = await client
                .from('zones')
                .select('id, zone_name')
                .eq('is_deleted', false)
                .order('zone_name', { ascending: true });

            if (error || !data || data.length === 0) {
                return ZONE_NAMES.map(name => ({ zone_name: name }));
            }

            return data;
        } catch (err) {
            console.error('Error getting zones:', err);
            return ZONE_NAMES.map(name => ({ zone_name: name }));
        }
    },

    async validateZonePassword(zoneName, password) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { data, error } = await client.rpc('validate_zone_password', {
            zone_name: zoneName,
            password: password
        });

        if (error) throw error;
        return data === true;
    },

    async getSchoolsByZone(zoneName) {
        const client = initializeSupabaseClient();
        if (!client) return [];

        try {
            const zone = await this._getZoneByName(zoneName);
            if (!zone) return [];

            const { data, error } = await client
                .from('schools')
                .select('id, school_name, school_code')
                .eq('zone_id', zone.id)
                .eq('is_deleted', false)
                .order('school_name', { ascending: true });

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error('Error getting schools:', err);
            return [];
        }
    },

    async _getZoneByName(zoneName) {
        const client = initializeSupabaseClient();
        const { data, error } = await client
            .from('zones')
            .select('id, zone_name')
            .eq('zone_name', zoneName)
            .eq('is_deleted', false)
            .single();

        if (error) return null;
        return data;
    },

    async addSchool(zoneName, schoolName) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const zone = await this._getZoneByName(zoneName);
        if (!zone) throw new Error('Zone not found');

        const schoolCode = schoolName.slice(0, 30).toUpperCase().replace(/\s+/g, '_');

        const { data, error } = await client
            .from('schools')
            .insert([{
                zone_id: zone.id,
                school_name: schoolName,
                school_code: schoolCode
            }])
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async getAllLearnersWithDetails() {
        const client = initializeSupabaseClient();
        if (!client) return [];

        try {
            const { data, error } = await client
                .from('learners')
                .select(`
                    id,
                    full_name,
                    lin,
                    sex,
                    class,
                    school_id,
                    schools (
                        id,
                        school_name,
                        zone_id,
                        zones (
                            zone_name
                        )
                    )
                `)
                .eq('is_deleted', false)
                .order('full_name', { ascending: true });

            if (error) throw error;

            return (data || []).map(learner => ({
                id: learner.id,
                name: learner.full_name,
                lin: learner.lin,
                sex: learner.sex,
                class: learner.class,
                school_id: learner.school_id,
                school_name: learner.schools?.school_name || 'Unknown',
                zone_name: learner.schools?.zones?.zone_name || 'Unknown'
            }));
        } catch (err) {
            console.error('Error getting learners:', err);
            return [];
        }
    },

    async getOrCreateLearner(fullName, lin, schoolId, sex, className, zoneName) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const zone = await this._getZoneByName(zoneName);
        if (!zone) throw new Error('Zone not found');

        const { data: existing, error: findError } = await client
            .from('learners')
            .select('*')
            .eq('lin', lin)
            .eq('is_deleted', false)
            .maybeSingle();

        if (findError) throw findError;

        if (existing) {
            if (existing.full_name !== fullName) {
                throw new Error('LIN already exists with different name');
            }
            return existing;
        }

        const { data, error } = await client
            .from('learners')
            .insert([{
                zone_id: zone.id,
                school_id: schoolId,
                full_name: fullName,
                lin: lin,
                sex: sex,
                class: className
            }])
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async deleteLearner(learnerId) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { error } = await client
            .from('learners')
            .update({ is_deleted: true, updated_at: new Date().toISOString() })
            .eq('id', learnerId);

        if (error) throw error;
        return true;
    },

    async saveResults(learnerId, schoolId, className, year, term, subjectScores, summaryData, zoneName) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const zone = await this._getZoneByName(zoneName);
        if (!zone) throw new Error('Zone not found');

        const termNum = parseTerm(term);
        if (!termNum) throw new Error('Invalid term');

        const { data: existingResult, error: findError } = await client
            .from('results')
            .select('id')
            .eq('learner_id', learnerId)
            .eq('year', parseInt(year, 10))
            .eq('term', termNum)
            .eq('is_deleted', false)
            .maybeSingle();

        if (findError) throw findError;

        let resultId;

        if (existingResult) {
            const { data, error } = await client
                .from('results')
                .update({
                    class: className,
                    overall_position: summaryData.position || 'N/A',
                    overall_comment: summaryData.overallComment || '',
                    subject_teacher_comment: summaryData.subjectTeacherComment || '',
                    head_teacher_comment: summaryData.headTeacherComment || '',
                    updated_at: new Date().toISOString()
                })
                .eq('id', existingResult.id)
                .select()
                .single();

            if (error) throw error;
            resultId = data.id;

            await client.from('result_subjects').delete().eq('result_id', resultId);
        } else {
            const { data, error } = await client
                .from('results')
                .insert([{
                    learner_id: learnerId,
                    zone_id: zone.id,
                    school_id: schoolId,
                    year: parseInt(year, 10),
                    term: termNum,
                    class: className,
                    overall_position: summaryData.position || 'N/A',
                    overall_comment: summaryData.overallComment || '',
                    subject_teacher_comment: summaryData.subjectTeacherComment || '',
                    head_teacher_comment: summaryData.headTeacherComment || ''
                }])
                .select()
                .single();

            if (error) throw error;
            resultId = data.id;
        }

        const subjectRows = Object.entries(subjectScores).map(([subject, score]) => ({
            result_id: resultId,
            subject_name: subject,
            exam_mark: Number(score.exam || 0),
            grade: calculateGrade(Number(score.exam || 0)),
            remarks: score.remarks || ''
        }));

        const { error: subjectError } = await client
            .from('result_subjects')
            .insert(subjectRows);

        if (subjectError) throw subjectError;

        return { id: resultId };
    },

    async findReportCard(zoneName, schoolId, className, lin, year, term) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const termNum = parseTerm(term);
        if (!termNum) throw new Error('Invalid term');

        const { data, error } = await client.rpc('fetch_report_card', {
            p_zone_name: zoneName,
            p_school_id: schoolId,
            p_class: className,
            p_lin: lin,
            p_year: parseInt(year, 10),
            p_term: termNum
        });

        if (error) throw error;
        return data;
    },

    async getResultForEditing(resultId) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { data, error } = await client
            .from('results')
            .select(`
                *,
                result_subjects (*)
            `)
            .eq('id', resultId)
            .eq('is_deleted', false)
            .single();

        if (error) throw error;
        return data;
    },

    // Super Admin Functions
    async getAllAdmins() {
        const client = initializeSupabaseClient();
        if (!client) return [];

        try {
            const { data, error } = await client
                .from('admins')
                .select('*')
                .order('full_name', { ascending: true });

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error('Error getting admins:', err);
            return [];
        }
    },

    async addAdmin(email, fullName, role = 'admin') {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { data, error } = await client
            .from('admins')
            .insert([{
                email,
                full_name: fullName,
                role
            }])
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async updateAdmin(adminId, updates) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { data, error } = await client
            .from('admins')
            .update(updates)
            .eq('id', adminId)
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async deleteAdmin(adminId) {
        const client = initializeSupabaseClient();
        if (!client) throw new Error('Supabase not configured');

        const { error } = await client
            .from('admins')
            .delete()
            .eq('id', adminId);

        if (error) throw error;
        return true;
    },

    async getAuditLogs() {
        const client = initializeSupabaseClient();
        if (!client) return [];

        try {
            const { data, error } = await client
                .from('audit_logs')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error('Error getting audit logs:', err);
            return [];
        }
    }
};

window.EduTrackDB = EduTrackDB;

// Initialize on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeSupabaseClient);
} else {
    initializeSupabaseClient();
}
