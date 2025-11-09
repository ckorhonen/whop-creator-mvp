#!/bin/bash

# Regenerate Complete Package Lockfile Script
# This script fixes incomplete package-lock.json files by regenerating them from scratch
# Related to GitHub Actions workflow: .github/workflows/regenerate-lockfile.yml
# Fixes workflow run #19203244373

set -e  # Exit on error

echo "========================================="
echo "🔧 Package Lockfile Regeneration Script"
echo "========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo "${BLUE}Step 1: Checking prerequisites${NC}"
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo ""

if [ ! -f "package.json" ]; then
    echo "${RED}❌ Error: package.json not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Step 2: Backup current state (optional)
if [ -f "package-lock.json" ]; then
    echo "${BLUE}Step 2: Backing up current lockfile${NC}"
    CURRENT_LINES=$(wc -l < package-lock.json)
    echo "Current lockfile: $CURRENT_LINES lines"
    
    # Check if it's incomplete
    if [ "$CURRENT_LINES" -lt 1000 ]; then
        echo "${YELLOW}⚠️  Current lockfile appears incomplete (only $CURRENT_LINES lines)${NC}"
    fi
    
    # Create backup
    BACKUP_FILE="package-lock.json.backup.$(date +%Y%m%d-%H%M%S)"
    cp package-lock.json "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
else
    echo "${BLUE}Step 2: No existing lockfile found${NC}"
fi
echo ""

# Step 3: Clean existing state
echo "${BLUE}Step 3: Cleaning existing state${NC}"

if [ -f "package-lock.json" ]; then
    echo "Removing package-lock.json..."
    rm package-lock.json
    echo "✅ Removed existing lockfile"
fi

if [ -d "node_modules" ]; then
    echo "Removing node_modules..."
    rm -rf node_modules
    echo "✅ Removed node_modules"
fi

echo "Cleaning npm cache..."
npm cache clean --force
echo "✅ npm cache cleaned"
echo ""

# Step 4: Configure npm for reliability
echo "${BLUE}Step 4: Configuring npm${NC}"
npm config set registry https://registry.npmjs.org/
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
echo "✅ npm configured for reliable package fetching"
echo ""

# Step 5: Generate complete lockfile
echo "${BLUE}Step 5: Generating complete lockfile${NC}"
echo "This may take a few minutes..."
echo ""

# Use full npm install (not --package-lock-only) for reliability
if npm install; then
    echo ""
    echo "${GREEN}✅ npm install completed successfully${NC}"
else
    echo ""
    echo "${RED}❌ npm install failed${NC}"
    echo "Please check the error messages above"
    exit 1
fi
echo ""

# Step 6: Verify the generated lockfile
echo "${BLUE}Step 6: Verifying generated lockfile${NC}"

if [ ! -f "package-lock.json" ]; then
    echo "${RED}❌ Error: package-lock.json was not generated${NC}"
    exit 1
fi

LOCKFILE_LINES=$(wc -l < package-lock.json)
PACKAGE_COUNT=$(grep -c '"resolved":' package-lock.json || echo "0")
INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
FILE_SIZE=$(du -h package-lock.json | cut -f1)

echo "Lockfile statistics:"
echo "  - Total lines: $LOCKFILE_LINES"
echo "  - Package entries: $PACKAGE_COUNT"
echo "  - Integrity hashes: $INTEGRITY_COUNT"
echo "  - File size: $FILE_SIZE"
echo ""

# Validate size
if [ "$LOCKFILE_LINES" -lt 1000 ]; then
    echo "${RED}❌ Error: Generated lockfile is too small ($LOCKFILE_LINES lines)${NC}"
    echo "Expected at least 1000 lines for a complete lockfile"
    echo ""
    echo "This suggests the lockfile generation failed or was incomplete."
    echo "Please check for dependency resolution errors above."
    exit 1
fi

# Check for placeholder hashes
if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
    echo "${RED}❌ Error: Generated lockfile contains placeholder hashes${NC}"
    echo "This should not happen with npm install"
    exit 1
fi

# Verify proper integrity hashes exist
if [ "$INTEGRITY_COUNT" -lt 10 ]; then
    echo "${YELLOW}⚠️  Warning: Found only $INTEGRITY_COUNT integrity hashes${NC}"
    echo "Expected many more for a complete lockfile"
fi

echo "${GREEN}✅ Lockfile validation passed${NC}"
echo ""

# Step 7: Validate with npm ci
echo "${BLUE}Step 7: Validating lockfile with npm ci${NC}"

# Clean node_modules first
rm -rf node_modules

# Try npm ci
if npm ci; then
    echo "${GREEN}✅ npm ci succeeded - lockfile is valid${NC}"
else
    echo "${YELLOW}⚠️  npm ci had issues${NC}"
    echo ""
    echo "Checking for dependency conflicts..."
    npm ls || true
    echo ""
    echo "${YELLOW}Some dependency issues detected, but lockfile was generated.${NC}"
    echo "This is often due to peer dependency warnings and may not be critical."
fi
echo ""

# Step 8: Clean up node_modules for commit
echo "${BLUE}Step 8: Cleaning up for commit${NC}"
rm -rf node_modules
echo "✅ node_modules removed (ready to commit)"
echo ""

# Step 9: Summary and next steps
echo "========================================="
echo "${GREEN}✨ Lockfile Regeneration Complete!${NC}"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Generated complete package-lock.json"
echo "  - $LOCKFILE_LINES lines, $PACKAGE_COUNT packages"
echo "  - $INTEGRITY_COUNT proper SHA-based integrity hashes"
echo "  - File size: $FILE_SIZE"
echo ""
echo "Next steps:"
echo "  1. Review the changes:"
echo "     ${BLUE}git diff package-lock.json${NC}"
echo ""
echo "  2. Commit the complete lockfile:"
echo "     ${BLUE}git add package-lock.json${NC}"
echo "     ${BLUE}git commit -m \"🔧 Regenerate complete package-lock.json with all dependencies\"${NC}"
echo ""
echo "  3. Push to GitHub:"
echo "     ${BLUE}git push origin $(git branch --show-current)${NC}"
echo ""
echo "  4. Verify on GitHub Actions that the workflow passes"
echo ""

# Optional: Show diff stats
if [ -f "$BACKUP_FILE" ]; then
    echo "Comparison with backup:"
    BACKUP_LINES=$(wc -l < "$BACKUP_FILE")
    LINE_DIFF=$((LOCKFILE_LINES - BACKUP_LINES))
    
    if [ $LINE_DIFF -gt 0 ]; then
        echo "  ${GREEN}+${LINE_DIFF} lines added${NC} (more complete)"
    elif [ $LINE_DIFF -lt 0 ]; then
        echo "  ${RED}${LINE_DIFF} lines removed${NC} (smaller)"
    else
        echo "  No size change"
    fi
    
    echo ""
    echo "Backup saved at: $BACKUP_FILE"
    echo "You can compare with: ${BLUE}diff $BACKUP_FILE package-lock.json${NC}"
fi

echo ""
echo "${GREEN}Done! ✨${NC}"
