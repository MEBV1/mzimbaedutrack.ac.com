#!/bin/bash

# MzimbaEduTrack Environment Setup Script
# Run this before deploying to set up environment variables

echo "======================================"
echo "MzimbaEduTrack - Environment Setup"
echo "======================================"
echo ""

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "❌ .env.local not found. Creating from template..."
    cp .env.local.example .env.local
    echo "✓ Created .env.local from template"
    echo ""
    echo "⚠️  Please edit .env.local with your Supabase credentials:"
    echo "   - VITE_SUPABASE_URL: Your Supabase project URL"
    echo "   - VITE_SUPABASE_ANON_KEY: Your Supabase anonymous key"
    echo ""
else
    echo "✓ .env.local already exists"
fi

echo ""
echo "For Cloudflare Pages deployment:"
echo "1. Add environment variables in Cloudflare Pages dashboard:"
echo "   - VITE_SUPABASE_URL"
echo "   - VITE_SUPABASE_ANON_KEY"
echo "   - VITE_APP_ENV=production"
echo ""
echo "2. In _headers file (if using), add CSP policies:"
echo "   connect-src 'self' https://*.supabase.co https://realtime.*.supabase.co"
echo ""
echo "For local development:"
echo "1. Ensure .env.local is populated with Supabase credentials"
echo "2. Run a local web server (e.g., python -m http.server 8000)"
echo "3. Open http://localhost:8000 in your browser"
echo ""
echo "======================================"
