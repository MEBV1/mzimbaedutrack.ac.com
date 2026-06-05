# MzimbaEduTrack - Quick Start Guide

## For Developers

### Local Development (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/yourusername/mzimbaedutrack.git
cd mzimbaedutrack

# 2. Setup environment
bash setup-local.sh

# 3. Edit .env.local with Supabase credentials
# VITE_SUPABASE_URL=https://your-project.supabase.co
# VITE_SUPABASE_ANON_KEY=your-key-here

# 4. Start local server
python -m http.server 8000
# or
npx serve

# 5. Open browser
# http://localhost:8000

# 6. Test admin portal
# Press Ctrl+Shift+M to activate admin login
```

### Deploying to Cloudflare Pages (10 minutes)

1. **In Cloudflare Dashboard:**
   - Create new Pages project
   - Connect to your Git repository
   - Build command: (leave blank)
   - Build output: `.`
   - Add environment variables:
     ```
     VITE_SUPABASE_URL = https://your-project.supabase.co
     VITE_SUPABASE_ANON_KEY = your-anon-key
     VITE_APP_ENV = production
     ```

2. **In Git:**
   ```bash
   git push origin main  # Auto-deploys to Cloudflare
   ```

3. **Verify:**
   - Check deployment status in Cloudflare
   - Test at your custom domain

---

## For End Users

### Public Portal (Student/Parent View)

1. Open application URL
2. Select Zone → School → Class Level
3. Enter Learner ID (16 digits)
4. Choose Academic Year and Term
5. Click "View Results"
6. Print or save PDF

### Admin Portal (Teacher/Officer View)

1. **Activate Admin**: Press Ctrl + Shift + M (hold for 3 seconds)
2. **Login**: 
   - Email: your-admin-email@example.com
   - Password: (provided)
3. **Select Zone**: Choose your zone
4. **Verify**: Enter zone password
5. **Dashboard**:
   - **Learners Tab**: Search learners, add results
   - **Results Tab**: 3-step wizard for report cards
   - **Schools Tab**: Create new schools

#### Adding Report Card (3 Steps)

**Step 1:**
- School: [Select]
- Class Level: [Select]
- Year: [Select]
- Term: [Select]
→ Click "Next"

**Step 2:**
- Fill subject scores:
  - Chichewa, English, Mathematics, Science & Tech, Social Studies, Agriculture, Life Skills, Expressive Arts
  - Continuous Assessment (0-40) + Exam (0-60) = Total (0-100)
  - System auto-calculates grade
- Add comments and promotion status
→ Click "Next"

**Step 3:**
- Learner Name: [Type full name]
- Gender: [Male/Female]
- Date of Birth: [Select]
- LIN: [16 digits]
→ Click "Upload & Save"

---

## Troubleshooting

### "Supabase configuration missing"
→ Set environment variables in Cloudflare dashboard or .env.local file

### "Admin account not found"
→ Verify admin email is in Supabase admins table

### "Zone password incorrect"
→ Check you selected correct zone and typed password correctly

### "Report card not found"
→ Verify all fields match exactly (Zone, School, Class, LIN, Year, Term)

### "Realtime not syncing"
→ Reload page and verify WebSocket connection in browser DevTools

---

## Key Concepts

### Learner ID (LIN)
- 16 digit unique identifier per learner
- Format: Numeric only
- Example: 1234567890123456

### Academic Year
- Format: 2026 (represents 2026/2027 academic year)
- Terms: 1 (Term One), 2 (Term Two), 3 (Term Three)

### Grading Scale
- A: 80-100
- B: 70-79
- C: 60-69
- D: 50-59
- F: 0-49

### Zone Codes
26 zones in Mzimba South District: CHASATO, CHIKANGAWA, CHIZUNGU, EDINGENI, EMFENI, ENDINDENI, EPHANGWENI, KABENA, KABUWA, KANJUCHI, KAPHUTA, KAPOLI, KATETE, KAVUULA, KAZINGILIRA, LUVIRI, LUWEREZI, MABIRI, MACHELECHETE, MANYAMULA, MHARAUNDA, MPHONGO, MZOMA, UNYOLO, VAZALA, VIBANGALALA

---

## Features Summary

✅ Secure public report retrieval  
✅ Hidden admin portal with multi-auth  
✅ Real-time multi-device synchronization  
✅ Complete report card management  
✅ Learner and school management  
✅ Print-to-PDF support  
✅ Mobile-responsive design  
✅ Installable as Android app  
✅ No passwords stored in plaintext  
✅ Automatic daily backups (Supabase)

---

## Support

For issues or questions:
1. Check browser console (F12) for errors
2. Verify Supabase connection status
3. Check deployment logs in Cloudflare
4. Contact IT Administrator

---

**Version**: 1.0.0  
**Last Updated**: June 2026  
**Environment**: Production Ready
