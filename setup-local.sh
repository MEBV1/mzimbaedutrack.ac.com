#!/bin/bash

# setup-local.sh - Local Development Setup Script
# Sets up environment variables and verifies configuration

set -e

echo "=================================="
echo "MzimbaEduTrack - Local Setup"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env.local exists
if [ -f ".env.local" ]; then
    echo -e "${YELLOW}⚠️  .env.local already exists${NC}"
    read -p "Overwrite with template? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env.local.example .env.local
        echo -e "${GREEN}✓ Reset .env.local from template${NC}"
    fi
else
    echo "Creating .env.local from template..."
    cp .env.local.example .env.local
    echo -e "${GREEN}✓ Created .env.local${NC}"
fi

echo ""
echo "Please edit .env.local with your Supabase credentials:"
echo "  VITE_SUPABASE_URL=https://your-project.supabase.co"
echo "  VITE_SUPABASE_ANON_KEY=eyJhbGc..."
echo ""

# Prompt to open editor
read -p "Open .env.local in editor? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v nano &> /dev/null; then
        nano .env.local
    elif command -v vi &> /dev/null; then
        vi .env.local
    else
        echo -e "${RED}No editor found. Please edit .env.local manually.${NC}"
    fi
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Verify .env.local contains your Supabase credentials"
echo "2. Run a local web server:"
echo "   python -m http.server 8000"
echo "   # or"
echo "   npx serve"
echo "3. Open http://localhost:8000 in your browser"
echo ""
echo -e "${GREEN}✓ Ready for development!${NC}"
