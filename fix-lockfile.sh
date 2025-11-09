#!/bin/bash

# Fix script for package-lock.json with placeholder integrity hashes
# Fixes workflow run #19203150843 - Deploy to Cloudflare Pages failure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Package-lock.json Integrity Hash Fix Script${NC}"
echo -e "${BLUE}  Fixes: Workflow #19203150843 Deployment Failure${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Check for placeholder hashes
echo -e "${YELLOW}[1/7] Checking for placeholder hashes...${NC}"
if grep -q '"integrity": "sha512-example' package-lock.json 2>/dev/null; then
    PLACEHOLDER_COUNT=$(grep -c '"integrity": "sha512-example' package-lock.json)
    echo -e "${RED}❌ Found ${PLACEHOLDER_COUNT} placeholder integrity hashes${NC}"
    echo -e "${YELLOW}   Affected packages include:${NC}"
    grep -B 2 '"integrity": "sha512-example' package-lock.json | grep '"node_modules/' | sed 's/.*"node_modules\///g' | sed 's/": {//g' | head -5
    echo -e "${YELLOW}   ... and $(($PLACEHOLDER_COUNT - 5)) more${NC}"
else
    echo -e "${GREEN}✅ No placeholder hashes found${NC}"
    echo -e "${GREEN}   Your lockfile may already be fixed!${NC}"
    exit 0
fi
echo ""

# Step 2: Create backup
echo -e "${YELLOW}[2/7] Creating backup...${NC}"
cp package-lock.json package-lock.json.backup
echo -e "${GREEN}✅ Backup created: package-lock.json.backup${NC}"
echo ""

# Step 3: Remove corrupted files
echo -e "${YELLOW}[3/7] Removing corrupted lockfile and node_modules...${NC}"
rm -f package-lock.json
rm -rf node_modules
echo -e "${GREEN}✅ Cleaned up corrupted files${NC}"
echo ""

# Step 4: Clear npm cache
echo -e "${YELLOW}[4/7] Clearing npm cache...${NC}"
npm cache clean --force
echo -e "${GREEN}✅ npm cache cleared${NC}"
echo ""

# Step 5: Regenerate lockfile
echo -e "${YELLOW}[5/7] Regenerating package-lock.json with real integrity hashes...${NC}"
echo -e "${BLUE}   This may take 2-3 minutes as npm downloads and verifies all packages${NC}"
npm install
echo -e "${GREEN}✅ package-lock.json regenerated${NC}"
echo ""

# Step 6: Verify the fix
echo -e "${YELLOW}[6/7] Verifying the fix...${NC}"
FILE_SIZE=$(wc -l < package-lock.json)
PLACEHOLDER_COUNT=$(grep -c '"integrity": "sha512-example' package-lock.json 2>/dev/null || echo 0)
REAL_HASH_COUNT=$(grep -c '"integrity": "sha512-' package-lock.json)

echo -e "${BLUE}   Lockfile size: ${FILE_SIZE} lines${NC}"
echo -e "${BLUE}   Placeholder hashes: ${PLACEHOLDER_COUNT}${NC}"
echo -e "${BLUE}   Real SHA-512 hashes: ${REAL_HASH_COUNT}${NC}"
echo ""

if [ "$PLACEHOLDER_COUNT" -eq 0 ] && [ "$FILE_SIZE" -gt 1000 ]; then
    echo -e "${GREEN}✅ Verification passed!${NC}"
    echo -e "${GREEN}   - Zero placeholder hashes${NC}"
    echo -e "${GREEN}   - ${REAL_HASH_COUNT} real integrity hashes${NC}"
    echo -e "${GREEN}   - Lockfile size: ${FILE_SIZE} lines${NC}"
else
    echo -e "${RED}❌ Verification failed${NC}"
    echo -e "${RED}   Please check the lockfile manually${NC}"
    exit 1
fi
echo ""

# Step 7: Test installation
echo -e "${YELLOW}[7/7] Testing with npm ci...${NC}"
if npm ci; then
    echo -e "${GREEN}✅ npm ci successful${NC}"
else
    echo -e "${RED}❌ npm ci failed${NC}"
    echo -e "${RED}   Please review the error above${NC}"
    exit 1
fi
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SUCCESS! package-lock.json has been fixed${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "${BLUE}1. Review the changes: git diff package-lock.json${NC}"
echo -e "${BLUE}2. Commit the fixed lockfile:${NC}"
echo -e "   git add package-lock.json"
echo -e "   git commit -m '🔧 Fix: Regenerate package-lock.json with real integrity hashes'"
echo -e "${BLUE}3. Push to GitHub:${NC}"
echo -e "   git push origin $(git branch --show-current)"
echo -e "${BLUE}4. Verify workflows pass in GitHub Actions${NC}"
echo ""
echo -e "${YELLOW}Backup saved as: package-lock.json.backup${NC}"
echo ""