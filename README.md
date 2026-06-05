# MzimbaEduTrack - Production-Ready Student Achievement Portal

A secure, real-time student report card management system for Mzimba South District Education.

## Features

✅ **Secure Student Report Retrieval** - Public portal for learners/parents to view report cards  
✅ **Hidden Admin Portal** - Activated by Ctrl+Shift+M with multi-level authentication  
✅ **Zone-Based Access Control** - Secure zone password validation  
✅ **Real-Time Synchronization** - Multi-device sync with Supabase Realtime  
✅ **Comprehensive Report Cards** - 8-subject matrix with CA/Exam scoring  
✅ **Learner Management** - Search, add, edit learners with duplicate prevention  
✅ **Results Management** - Full CRUD with soft-delete and historical preservation  
✅ **School Management** - Create and manage schools per zone  
✅ **Print-Friendly** - Generate PDF report cards directly from browser  
✅ **PWA Support** - Installable as app on web and Android (Capacitor)  
✅ **Glassmorphic UI** - Modern, responsive design optimized for mobile

## Architecture

### Technology Stack
- **Frontend**: Vanilla JavaScript, HTML5, CSS3 (no frameworks)
- **Backend**: Supabase PostgreSQL with Row-Level Security (RLS)
- **Realtime**: Supabase Realtime for multi-device synchronization
- **Authentication**: Supabase Auth + Custom Zone Password Validation
- **Deployment**: Cloudflare Pages (web), Capacitor (Android)

### Project Structure
```
MzimbaEduTrack/
├── index.html              # Main UI with all sections
├── app.js                  # Application logic & event handlers
├── supabase.js             # Enhanced database abstraction layer
├── config.js               # Configuration management system
├── realtime.js             # Realtime synchronization engine
├── style.css               # Glassmorphic styling
├── schema.sql              # PostgreSQL schema with RLS
├── capacitor.config.json   # Android build configuration
├── wrangler.toml           # Cloudflare Pages configuration
├── .env.local.example      # Environment variables template
└── icons/                  # App icons (192px, 512px)
```

## Deployment Guide

### Prerequisites
- Supabase account (https://supabase.com)
- Cloudflare account (https://cloudflare.com) for Pages
- Git repository (GitHub, GitLab, etc.)
- Capacitor CLI for Android builds (optional)

### 1. Create Supabase Project

1. Go to https://supabase.com and create a new project
2. Note your project URL and anon key
3. Go to SQL Editor and paste contents of `schema.sql`
4. Execute the schema to create all tables and functions
5. Enable authentication: Auth → Settings → Enable Email/Password

### 2. Set Up Admin User

1. In Supabase, go to Authentication → Users
2. Click "Create New User" and add admin email + password
3. Go to SQL Editor and run:
```sql
INSERT INTO admins (email, role)
VALUES ('your-admin-email@example.com', 'Zone Officer')
ON CONFLICT (email) DO NOTHING;
```

### 3. Prepare Environment Variables

1. Copy `.env.local.example` to `.env.local`
2. Fill in Supabase credentials:
```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
```
3. **DO NOT commit .env.local to version control**

### 4. Deploy to Cloudflare Pages

1. Push code to GitHub (or connect preferred Git provider)
2. In Cloudflare dashboard:
   - Create new Pages project
   - Connect to your Git repository
   - Set build command: (leave blank or `echo 'Static site'`)
   - Set build output directory: `.` (root)
   - Add Environment Variables:
     - `VITE_SUPABASE_URL`: Your Supabase project URL
     - `VITE_SUPABASE_ANON_KEY`: Your Supabase anon key
     - `VITE_APP_ENV`: `production`
     - `VITE_ENABLE_REALTIME`: `true`
3. Deploy by committing to main branch

### 5. Configure Supabase Realtime (for multi-device sync)

1. In Supabase dashboard, go to Database → Replication
2. Enable replication for tables:
   - `learners`
   - `results`
   - `schools`
   - `result_subjects`
3. Realtime will automatically activate for admin sessions

### 6. Build Android APK (Optional)

```bash
# Install Capacitor CLI
npm install -g @capacitor/cli

# Initialize Capacitor in project directory
npx cap init

# Add Android platform
npx cap add android

# Copy web assets
npx cap copy

# Build and open in Android Studio
npx cap open android
```

Then in Android Studio:
1. Build → Generate Signed Bundle/APK
2. Create keystore for signing
3. Build and sign release APK

## Usage Guide

### For Students/Parents (Public Portal)

1. Open the application
2. Select Zone → School → Class Level → Enter LIN
3. Choose Academic Year → Term
4. Click "View Results"
5. Print as PDF or screenshot

### For Administrators (Hidden Portal)

1. **Activate Admin**: Press Ctrl + Shift + M for 3 seconds
2. **Login**: Enter admin email and password
3. **Select Zone**: Choose zone from dropdown, click "Proceed"
4. **Verify Zone**: Enter zone password (provided by zone officer)
5. **Admin Dashboard** tabs:
   - **View & Search Learners**: Search by name or LIN, add results
   - **Add New Results**: 3-step wizard for report card entry
   - **Manage Schools**: Create schools in zone

### Report Card Entry (3-Step Wizard)

**Step 1: School & Class**
- Select target school
- Choose class level (Std 5-8)
- Select academic year and term
- Click "Next"

**Step 2: Subject Scores Matrix**
- Fill continuous assessment (max 40) and exam (max 60)
- System auto-calculates totals and grades
- Add class position and teacher comments
- Select promotion status
- Click "Next"

**Step 3: Learner Verification**
- Enter learner full name
- Select gender and date of birth
- Enter 16-digit LIN (Learner Identification Number)
- Click "Upload & Save"

## Security Features

### Authentication
- **Two-Factor**: Email/password + zone password
- **Role-Based Access Control**: Admin-only via Supabase Auth RLS policies
- **Zone Isolation**: Admins only see data for their zone
- **Password Hashing**: Zone passwords stored as salted SHA-256 hashes

### Data Protection
- **Soft Deletes**: Records marked deleted, not removed from database
- **Audit Logging**: All admin actions tracked in audit_logs table
- **Encryption**: Supabase encrypts data in transit (HTTPS) and at rest
- **RLS Policies**: Public reads allowed for zones/schools, authenticated writes only

### Compliance
- **GDPR Compatible**: Data retention policies, soft-delete support
- **Learner Privacy**: LIN-based retrieval prevents data leakage
- **Audit Trail**: Full history of all modifications

## Real-Time Synchronization

When an administrator uploads report card data:
1. Data saves to Supabase PostgreSQL
2. Supabase Realtime broadcasts change to subscribed clients
3. All connected devices automatically refresh relevant sections
4. No manual page refresh required

Subscribed tables:
- `learners` - Learner roster changes
- `results` - Report card submissions
- `schools` - School roster changes
- `result_subjects` - Subject score updates

## Configuration & Environment Variables

### Available Configuration Keys

| Variable | Default | Description |
|----------|---------|-------------|
| `VITE_SUPABASE_URL` | - | Supabase project URL (REQUIRED) |
| `VITE_SUPABASE_ANON_KEY` | - | Supabase anonymous key (REQUIRED) |
| `VITE_APP_ENV` | `production` | Environment: `production` or `development` |
| `VITE_APP_NAME` | `MzimbaEduTrack` | Application name |
| `VITE_APP_VERSION` | `1.0.0` | Application version |
| `VITE_ENABLE_REALTIME` | `true` | Enable Supabase Realtime sync |
| `VITE_ENABLE_OFFLINE_MODE` | `false` | Enable offline support (beta) |
| `VITE_ENABLE_DEBUG_LOGGING` | `false` | Enable debug console logging |

### For Cloudflare Pages

Set in Cloudflare dashboard under Pages → Settings → Environment Variables:
```
VITE_SUPABASE_URL = https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY = eyJhbGc...
VITE_APP_ENV = production
```

## Error Resolution

### "Supabase configuration missing"
- Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
- Restart development server or redeploy

### "Admin account is not authorized"
- Verify admin email is registered in `admins` table
- Run SQL: `INSERT INTO admins (email, role) VALUES ('your@email.com', 'Zone Officer')`

### "Zone password incorrect"
- Verify zone password matches database hash
- Check zone name capitalization (must be UPPERCASE)

### "Realtime not connecting"
- Ensure Replication is enabled for relevant tables in Supabase
- Check browser console for connection errors
- Verify CSP allows `https://realtime.*.supabase.co`

## Database Schema Summary

### Zones Table
- Stores 26 Mzimba zones with salted SHA-256 password hashes
- Zone passwords validated server-side via RPC function

### Schools Table
- Foreign key to zones
- Supports multiple schools per zone

### Learners Table
- 16-digit LIN as unique identifier
- Soft-delete support (is_deleted, deleted_at)
- Records linked to schools

### Results Table
- Stores term results by learner
- Unique constraint: learner_id + class_name + term + year
- Soft-delete support
- JSONB summary_data for flexibility

### Result Subjects Table
- Individual subject scores (CA + Exam = Total)
- 8 standard Malawian subjects
- Grade calculation (A-F)

### Audit Logs Table
- Tracks all admin modifications
- Stores before/after JSONB data

## Performance Optimizations

- **Indexed Lookups**: Zone, school, learner, and result queries optimized
- **Soft Deletes**: Filtered at query level (WHERE is_deleted = FALSE)
- **Realtime Filtering**: Subscriptions scoped to relevant records
- **Lazy Loading**: Data loaded on-demand, not preloaded
- **Caching**: Localizable learner list for quick filtering

## Troubleshooting

### Blank Screen
1. Check browser console for JavaScript errors
2. Verify `config.js` and `realtime.js` are loaded
3. Check Supabase credentials in environment variables

### Realtime Not Syncing
1. Open browser DevTools → Network
2. Verify WebSocket connections to `realtime.*.supabase.co`
3. Check Supabase Replication is enabled
4. Refresh browser or re-authenticate

### Slow Report Card Loading
1. Check browser console for query timing
2. Ensure database indexes are created (run schema.sql)
3. Verify Supabase project is on active tier (not paused)
4. Check network latency (CloudFlare analytics)

## Support & Maintenance

### Regular Tasks
- **Weekly**: Monitor Supabase usage and quotas
- **Monthly**: Review audit logs for anomalies
- **Quarterly**: Update dependencies (Supabase client library)
- **Annually**: Review and update zone passwords

### Backup Strategy
- Supabase automated daily backups (free tier)
- Export reports periodically (via SQL export)
- Keep .env.local in secure, encrypted location

### Version Updates
To update Supabase library:
```html
<!-- Current version in use -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

<!-- Pin to specific version for stability -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.33.0"></script>
```

## License

Proprietary - For Mzimba South District Education Use Only

## Contact

For support or issues, contact the IT Administrator.

---

**Last Updated**: June 2026  
**Version**: 1.0.0  
**Environment**: Production
