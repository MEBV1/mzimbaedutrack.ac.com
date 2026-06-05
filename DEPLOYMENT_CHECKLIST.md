# MzimbaEduTrack - Deployment Checklist

## Pre-Deployment (Local Development)

### Code Quality
- [ ] All console errors resolved
- [ ] No console warnings about Supabase configuration
- [ ] All functions execute without errors
- [ ] Realtime listeners initialized successfully
- [ ] Soft-delete queries filter correctly (WHERE is_deleted = FALSE)

### Configuration
- [ ] `.env.local` created with valid Supabase credentials
- [ ] `config.js` loads without errors
- [ ] `realtime.js` initializes after Supabase client
- [ ] `supabase.js` uses Config system, not hardcoded credentials

### Testing
- [ ] Public portal: Zone dropdown populates
- [ ] Public portal: School dropdown populates based on zone
- [ ] Public portal: Report card retrieval works
- [ ] Admin: Ctrl+Shift+M activates login modal
- [ ] Admin: Login with valid credentials succeeds
- [ ] Admin: Zone selection and password verification works
- [ ] Admin: Learner list displays all learners in zone
- [ ] Admin: Report card wizard works end-to-end
- [ ] Admin: Realtime listeners set up without errors
- [ ] Print: Report card prints as PDF correctly

### Security
- [ ] No Supabase credentials in HTML/CSS/JavaScript
- [ ] .env.local is listed in .gitignore
- [ ] CSP headers configured in wrangler.toml
- [ ] Zone passwords stored as hashes, not plain text
- [ ] No console.log statements exposing sensitive data

---

## Supabase Project Setup

### Database Schema
- [ ] Run `schema.sql` in Supabase SQL Editor
- [ ] Verify `zones` table has 26 zones with hashed passwords
- [ ] Verify `schools`, `learners`, `results`, `result_subjects` tables created
- [ ] Verify soft-delete columns: `is_deleted`, `deleted_at` on learners & results
- [ ] Verify indexes created for performance
- [ ] Verify RLS policies enabled on all tables

### Authentication & Admin
- [ ] Create Supabase Auth user for admin email
- [ ] Insert admin record: `INSERT INTO admins (email, role) VALUES ('...', 'Zone Officer')`
- [ ] Test admin login with Supabase Auth

### Realtime Setup
- [ ] Go to Database → Replication in Supabase dashboard
- [ ] Enable replication for:
  - [ ] learners
  - [ ] results
  - [ ] schools
  - [ ] result_subjects
- [ ] Test realtime connection from browser

### Backup
- [ ] Verify Supabase daily automated backups enabled
- [ ] Test restore process on development database
- [ ] Document backup schedule

---

## Cloudflare Pages Deployment

### Repository Setup
- [ ] Code pushed to GitHub/GitLab
- [ ] `.env.local` added to `.gitignore`
- [ ] No Supabase credentials in version control
- [ ] All required files in repository:
  - [ ] index.html
  - [ ] app.js, supabase.js, config.js, realtime.js
  - [ ] style.css
  - [ ] manifest.json
  - [ ] icons/ directory
  - [ ] wrangler.toml

### Cloudflare Configuration
- [ ] Create new Cloudflare Pages project
- [ ] Connect to Git repository
- [ ] Build settings:
  - [ ] Build command: (leave empty)
  - [ ] Build output directory: `.`
  - [ ] Root directory: (leave empty)
- [ ] Environment variables set:
  - [ ] `VITE_SUPABASE_URL` = `https://xxxxx.supabase.co`
  - [ ] `VITE_SUPABASE_ANON_KEY` = (from Supabase API Keys)
  - [ ] `VITE_APP_ENV` = `production`
  - [ ] `VITE_ENABLE_REALTIME` = `true`
  - [ ] `VITE_ENABLE_DEBUG_LOGGING` = `false`
- [ ] Build triggers on: Push to main branch

### Deployment & Verification
- [ ] Initial build completes successfully
- [ ] Deployed site loads without errors
- [ ] Public portal works (zone selection, report retrieval)
- [ ] Admin portal works (Ctrl+Shift+M, login, zone management)
- [ ] Realtime WebSocket connection established
- [ ] CSP headers passed (no console warnings)
- [ ] HTTPS enforced
- [ ] Performance metrics acceptable (<2s load time)

---

## Android Build (Capacitor)

### Environment Setup
- [ ] Install Node.js and npm
- [ ] Install Capacitor CLI: `npm install -g @capacitor/cli`
- [ ] Install Android Studio with SDK level 30+
- [ ] Set ANDROID_HOME environment variable

### Build Process
- [ ] Run: `npx cap init`
- [ ] Configure: app name, bundle ID `com.mzimbaedutrack.app`
- [ ] Run: `npx cap add android`
- [ ] Run: `npx cap copy`
- [ ] Run: `npx cap open android`

### Android Studio
- [ ] Open Android project in Android Studio
- [ ] Verify: Build → Sync Now succeeds
- [ ] Build release:
  - [ ] Build → Generate Signed Bundle/APK
  - [ ] Create new keystore (store safely)
  - [ ] Build type: APK Release
  - [ ] Sign and build
- [ ] Test on emulator: Run → Run app
- [ ] Test on physical device: Connect via USB debugging

### APK Distribution
- [ ] Store keystore file securely (backup copy)
- [ ] Rename APK: `MzimbaEduTrack_v1.0.0.apk`
- [ ] Calculate SHA-256 checksum
- [ ] Document release notes
- [ ] Upload to distribution platform (Google Play, etc.)

---

## Post-Deployment Monitoring

### First 24 Hours
- [ ] Monitor error logs in Supabase
- [ ] Check Cloudflare Analytics dashboard
- [ ] Verify no 4xx/5xx errors
- [ ] Test admin functionality with test account
- [ ] Verify realtime sync working with multiple devices

### First Week
- [ ] Review Supabase usage metrics
- [ ] Check for any performance issues
- [ ] Verify all RLS policies working correctly
- [ ] Monitor API quota usage
- [ ] Test backup/restore process

### Ongoing
- [ ] Weekly: Review audit logs for anomalies
- [ ] Monthly: Check Supabase maintenance notifications
- [ ] Monthly: Verify realtime subscriptions active
- [ ] Quarterly: Review and update security policies
- [ ] Quarterly: Update Supabase client library

---

## Rollback Plan

### If Production Issue Found
1. [ ] Identify issue in development environment
2. [ ] Create hotfix branch
3. [ ] Test thoroughly in development
4. [ ] Push to main branch → Cloudflare auto-deploys
5. [ ] Verify fix in production
6. [ ] Monitor for 2 hours

### If Database Issue Found
1. [ ] Notify all admins to stop work
2. [ ] Stop accepting new submissions
3. [ ] Restore from latest Supabase backup
4. [ ] Verify data integrity
5. [ ] Re-enable system

### If Credentials Compromised
1. [ ] Rotate Supabase anon key immediately
2. [ ] Update all environment variables (Cloudflare, Android config)
3. [ ] Force re-authentication of all admin sessions
4. [ ] Review audit logs for unauthorized access
5. [ ] Generate new credentials, test, deploy

---

## Success Criteria

✅ **All items checked**  
✅ **No console errors or warnings**  
✅ **Admin can upload report cards**  
✅ **Students can retrieve own report cards**  
✅ **Realtime sync working (multi-device)**  
✅ **Print functionality working**  
✅ **Android APK installable and functional**  
✅ **HTTPS/Security enforced**  
✅ **Backup strategy tested**

---

## Sign-Off

**Deployment Date**: ________________  
**Deployed By**: ________________  
**Verified By**: ________________  
**Environment**: Production ☐ Staging ☐  

**Notes**:  
_________________________________  
_________________________________  
_________________________________

---

**Version**: 1.0.0  
**Last Updated**: June 2026
