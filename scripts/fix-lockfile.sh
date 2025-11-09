#!/bin/bash
set -e

echo "================================"
echo "Fixing package-lock.json"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if package-lock.json exists and has placeholder hashes
if [ -f package-lock.json ]; then
    echo "Checking current lockfile..."
    
    PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
    
    if [ "$PLACEHOLDER_COUNT" -gt "0" ]; then
        echo -e "${RED}❌ Found $PLACEHOLDER_COUNT placeholder integrity hashes${NC}"
        echo ""
        echo "Example placeholders found:"
        grep -n "example-.*-hash" package-lock.json | head -5
        echo ""
    else
        echo -e "${GREEN}✅ No placeholder hashes found${NC}"
        echo "Lockfile appears to be valid"
        exit 0
    fi
else
    echo -e "${YELLOW}⚠️  No package-lock.json found${NC}"
fi

# Remove the problematic lockfile
echo ""
echo "Removing incomplete lockfile..."
rm -f package-lock.json
echo -e "${GREEN}✅ Removed package-lock.json${NC}"

# Regenerate with real integrity hashes
echo ""
echo "Regenerating package-lock.json with real integrity hashes..."
echo "This will download metadata for all packages..."
npm install --package-lock-only

# Verify the fix
echo ""
echo "Verifying the new lockfile..."

if [ ! -f package-lock.json ]; then
    echo -e "${RED}❌ Failed to generate package-lock.json${NC}"
    exit 1
fi

# Check for remaining placeholders
REMAINING_PLACEHOLDERS=$(grep -c "example-.*-hash" package-lock.json || echo "0")

if [ "$REMAINING_PLACEHOLDERS" -gt "0" ]; then
    echo -e "${RED}❌ ERROR: Still found $REMAINING_PLACEHOLDERS placeholder hashes!${NC}"
    echo "This should not happen. Something is wrong with the npm registry or network."
    exit 1
fi

# Count real integrity hashes
REAL_INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")

if [ "$REAL_INTEGRITY_COUNT" -gt "0" ]; then
    echo -e "${GREEN}✅ Generated $REAL_INTEGRITY_COUNT real integrity hashes${NC}"
else
    echo -e "${RED}❌ ERROR: No integrity hashes found${NC}"
    exit 1
fi

# Show lockfile stats
echo ""
echo "================================"
echo "Lockfile Statistics"
echo "================================"
echo "Total lines: $(wc -l < package-lock.json)"
echo "Total packages with resolved URLs: $(grep -c '"resolved":' package-lock.json || echo '0')"
echo "Total integrity hashes: $REAL_INTEGRITY_COUNT"
echo "File size: $(du -h package-lock.json | cut -f1)"
echo ""

echo -e "${GREEN}✅ SUCCESS: package-lock.json has been regenerated with real integrity hashes${NC}"
echo ""
echo "You can now commit this file:"
echo "  git add package-lock.json"
echo "  git commit -m '🔧 Regenerate package-lock.json with real integrity hashes'"
echo "  git push"
