#!/bin/bash
set -e

echo "========================================="
echo "Automated Lockfile Fix Script"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found. Run this script from the repository root.${NC}"
    exit 1
fi

echo "📋 Current Status Check:"
echo "------------------------"

# Check for placeholder hashes
if [ -f "package-lock.json" ]; then
    PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json 2>/dev/null || echo "0")
    if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Found $PLACEHOLDER_COUNT placeholder integrity hashes${NC}"
        echo "   Listing affected packages:"
        grep -n "example-.*-hash" package-lock.json | head -10
        echo ""
    else
        echo -e "${GREEN}✅ No placeholder hashes found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No package-lock.json found${NC}"
fi

echo ""
echo "🔧 Fixing lockfile..."
echo "--------------------"

# Step 1: Remove old lockfile
if [ -f "package-lock.json" ]; then
    echo "1️⃣  Removing incomplete package-lock.json..."
    rm package-lock.json
    echo -e "${GREEN}   ✅ Removed${NC}"
else
    echo "1️⃣  No existing lockfile to remove"
fi

# Step 2: Clean npm cache (optional but recommended)
echo ""
echo "2️⃣  Cleaning npm cache..."
npm cache clean --force 2>/dev/null || true
echo -e "${GREEN}   ✅ Cache cleaned${NC}"

# Step 3: Remove node_modules (fresh start)
if [ -d "node_modules" ]; then
    echo ""
    echo "3️⃣  Removing node_modules for clean install..."
    rm -rf node_modules
    echo -e "${GREEN}   ✅ Removed${NC}"
fi

# Step 4: Generate fresh lockfile
echo ""
echo "4️⃣  Generating fresh package-lock.json..."
echo "   This will download and verify all dependencies..."
npm install

if [ ! -f "package-lock.json" ]; then
    echo -e "${RED}❌ Error: Failed to generate package-lock.json${NC}"
    exit 1
fi

echo -e "${GREEN}   ✅ Generated${NC}"

# Step 5: Verify the lockfile
echo ""
echo "📊 Verification:"
echo "----------------"

# Check for placeholder hashes
PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json 2>/dev/null || echo "0")
if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ ERROR: Lockfile still contains $PLACEHOLDER_COUNT placeholder hashes!${NC}"
    echo "   This should not happen. Showing problematic entries:"
    grep -n "example-.*-hash" package-lock.json | head -10
    exit 1
else
    echo -e "${GREEN}✅ No placeholder hashes${NC}"
fi

# Check for real integrity hashes
INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json 2>/dev/null || echo "0")
echo -e "${GREEN}✅ Found $INTEGRITY_COUNT proper integrity hashes${NC}"

# Get file size and line count
LINES=$(wc -l < package-lock.json)
SIZE=$(du -h package-lock.json | cut -f1)
echo -e "${GREEN}✅ Lockfile: $LINES lines, $SIZE${NC}"

# Run npm ls to verify
echo ""
echo "5️⃣  Verifying dependency tree..."
if npm ls > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ All dependencies resolved correctly${NC}"
else
    echo -e "${YELLOW}   ⚠️  Some warnings (this is often normal)${NC}"
    npm ls 2>&1 | head -20
fi

echo ""
echo "========================================="
echo -e "${GREEN}✨ Fix Complete!${NC}"
echo "========================================="
echo ""
echo "📝 Next Steps:"
echo "1. Review the changes:"
echo "   git diff package-lock.json | head -100"
echo ""
echo "2. Commit and push:"
echo "   git add package-lock.json"
echo "   git commit -m '🔧 Fix: Regenerate package-lock.json with real integrity hashes'"
echo "   git push origin automated-lockfile-fix"
echo ""
echo "3. Re-run the GitHub Actions workflow"
echo ""
