#!/bin/bash
set -e

echo "🔍 Automated Lockfile Fix Script"
echo "=================================="
echo ""

# Check if we're on the right branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Backup existing lockfile
if [ -f "package-lock.json" ]; then
    echo "📦 Backing up existing package-lock.json..."
    cp package-lock.json package-lock.json.backup
    echo "✅ Backup created: package-lock.json.backup"
fi

# Clean npm state
echo ""
echo "🧹 Cleaning npm cache and node_modules..."
rm -rf node_modules
npm cache clean --force
echo "✅ Clean complete"

# Delete existing incomplete lockfile
echo ""
echo "🗑️  Removing incomplete lockfile..."
rm -f package-lock.json
echo "✅ Removed"

# Regenerate complete lockfile
echo ""
echo "🔨 Regenerating complete package-lock.json with integrity hashes..."
npm install --package-lock-only

if [ ! -f "package-lock.json" ]; then
    echo "❌ ERROR: Failed to generate package-lock.json"
    exit 1
fi
echo "✅ package-lock.json regenerated"

# Verify the fix
echo ""
echo "🔍 Verifying lockfile integrity..."

# Check total packages
TOTAL_PACKAGES=$(node -e "const pkg = require('./package-lock.json'); console.log(Object.keys(pkg.packages || {}).length)")
echo "📊 Total packages: $TOTAL_PACKAGES"

# Count packages with integrity
INTEGRITY_COUNT=$(node -e "const pkg = require('./package-lock.json'); console.log(Object.values(pkg.packages || {}).filter(p => p.integrity).length)")
echo "📊 Packages with integrity: $INTEGRITY_COUNT"

# Check for placeholder hashes
if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
    echo "❌ ERROR: Found placeholder integrity hashes!"
    exit 1
fi
echo "✅ No placeholder hashes found"

# Verify minimum package count
if [ "$TOTAL_PACKAGES" -lt 10 ]; then
    echo "❌ ERROR: Lockfile appears incomplete (only $TOTAL_PACKAGES packages)"
    exit 1
fi
echo "✅ Lockfile appears complete ($TOTAL_PACKAGES packages)"

# Test installation
echo ""
echo "🧪 Testing npm ci with new lockfile..."
rm -rf node_modules
npm ci --quiet
echo "✅ npm ci successful"

# Summary
echo ""
echo "✨ Fix Complete!"
echo "==============="
echo ""
echo "Summary:"
echo "  - Total packages: $TOTAL_PACKAGES"
echo "  - Packages with integrity: $INTEGRITY_COUNT"
echo "  - npm ci: ✅ PASSED"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff package-lock.json"
echo "  2. Commit: git add package-lock.json"
echo "  3. Commit: git commit -m 'fix: Regenerate complete package-lock.json with integrity hashes'"
echo "  4. Push: git push"
echo ""
echo "🎉 Lockfile is now ready for production!"
