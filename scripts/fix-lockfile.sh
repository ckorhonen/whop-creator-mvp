#!/bin/bash
# Automated Lockfile Fix Script
# This script regenerates package-lock.json with real integrity hashes

set -e  # Exit on error

echo "🔧 Lockfile Integrity Fix Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Backup current lockfile
echo "📦 Step 1: Backing up current lockfile..."
if [ -f "package-lock.json" ]; then
    cp package-lock.json package-lock.json.backup
    echo -e "${GREEN}✅ Backup created: package-lock.json.backup${NC}"
else
    echo -e "${YELLOW}⚠️  No existing lockfile found${NC}"
fi

# Step 2: Remove corrupted lockfile and node_modules
echo ""
echo "🗑️  Step 2: Removing corrupted files..."
rm -f package-lock.json
rm -rf node_modules
echo -e "${GREEN}✅ Removed package-lock.json and node_modules${NC}"

# Step 3: Clear npm cache
echo ""
echo "🧹 Step 3: Clearing npm cache..."
npm cache clean --force
echo -e "${GREEN}✅ npm cache cleared${NC}"

# Step 4: Regenerate lockfile
echo ""
echo "🔄 Step 4: Regenerating lockfile with real integrity hashes..."
echo "   This may take 2-3 minutes for first-time installation..."
npm install
echo -e "${GREEN}✅ Lockfile regenerated${NC}"

# Step 5: Verify the fix
echo ""
echo "🔍 Step 5: Verifying the fix..."
echo ""

# Check for placeholder hashes
PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
if [ "$PLACEHOLDER_COUNT" -eq "0" ]; then
    echo -e "${GREEN}✅ No placeholder hashes found!${NC}"
else
    echo -e "${RED}❌ ERROR: Still has $PLACEHOLDER_COUNT placeholder hashes${NC}"
    echo "   Please check the lockfile manually."
    exit 1
fi

# Check for real integrity hashes
REAL_HASH_COUNT=$(grep -c '"integrity": "sha' package-lock.json)
echo -e "${GREEN}✅ Found $REAL_HASH_COUNT real integrity hashes${NC}"

# Check lockfile size
LINE_COUNT=$(wc -l < package-lock.json)
echo -e "${GREEN}✅ Lockfile has $LINE_COUNT lines${NC}"

if [ "$LINE_COUNT" -lt "1000" ]; then
    echo -e "${YELLOW}⚠️  WARNING: Lockfile may be incomplete (<1000 lines)${NC}"
    echo "   Expected 8000+ lines for complete dependency tree."
fi

# Step 6: Test with npm ci
echo ""
echo "🧪 Step 6: Testing with npm ci..."
npm ci
echo -e "${GREEN}✅ npm ci succeeded!${NC}"

# Step 7: Test build
echo ""
echo "🏗️  Step 7: Testing build..."
npm run build
echo -e "${GREEN}✅ Build succeeded!${NC}"

# Summary
echo ""
echo "========================================="
echo -e "${GREEN}🎉 SUCCESS! Lockfile has been fixed!${NC}"
echo "========================================="
echo ""
echo "📊 Summary:"
echo "  - Placeholder hashes: $PLACEHOLDER_COUNT (should be 0)"
echo "  - Real integrity hashes: $REAL_HASH_COUNT"
echo "  - Lockfile lines: $LINE_COUNT"
echo ""
echo "📝 Next steps:"
echo "  1. Review changes: git diff package-lock.json"
echo "  2. Commit: git add package-lock.json"
echo "  3. Commit: git commit -m '🔧 Fix: Regenerate package-lock.json with real integrity hashes'"
echo "  4. Push: git push origin $(git branch --show-current)"
echo ""
echo "✅ Your lockfile is now ready to commit!"
