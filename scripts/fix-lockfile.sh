#!/bin/bash
set -e

echo "======================================"
echo "🔧 Fixing package-lock.json Integrity"
echo "======================================"
echo ""

# Step 1: Backup current lockfile
echo "📋 Step 1: Backing up current lockfile..."
if [ -f package-lock.json ]; then
    cp package-lock.json package-lock.json.backup
    echo "✅ Backup created: package-lock.json.backup"
else
    echo "⚠️  No existing lockfile found"
fi
echo ""

# Step 2: Check for placeholder hashes
echo "🔍 Step 2: Checking for placeholder hashes..."
if [ -f package-lock.json ]; then
    PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
    echo "Found $PLACEHOLDER_COUNT placeholder hashes"
    
    if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
        echo "❌ Placeholder hashes detected:"
        grep "example-.*-hash" package-lock.json | head -10
    fi
fi
echo ""

# Step 3: Clean everything
echo "🧹 Step 3: Cleaning npm cache and removing old files..."
rm -rf node_modules
rm -f package-lock.json
npm cache clean --force
echo "✅ Cleaned npm cache, node_modules, and old lockfile"
echo ""

# Step 4: Generate new lockfile
echo "📦 Step 4: Generating new package-lock.json with real integrity hashes..."
echo "This will download all packages and verify their integrity..."
npm install
echo "✅ New lockfile generated"
echo ""

# Step 5: Verify the fix
echo "✅ Step 5: Verifying the fix..."
if [ ! -f package-lock.json ]; then
    echo "❌ ERROR: package-lock.json was not generated!"
    exit 1
fi

# Check file size
FILE_SIZE=$(du -k package-lock.json | cut -f1)
echo "Lockfile size: $(du -h package-lock.json | cut -f1)"
echo "Lockfile lines: $(wc -l < package-lock.json)"

if [ "$FILE_SIZE" -lt 10 ]; then
    echo "❌ ERROR: Lockfile is too small (< 10KB)"
    exit 1
fi

# Check for remaining placeholder hashes
PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
echo "Placeholder hashes remaining: $PLACEHOLDER_COUNT"

if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
    echo "❌ ERROR: Still found $PLACEHOLDER_COUNT placeholder hashes!"
    echo "Problematic entries:"
    grep -n "example-.*-hash" package-lock.json | head -10
    exit 1
fi

# Count real integrity hashes
REAL_INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
echo "Real SHA integrity hashes: $REAL_INTEGRITY_COUNT"

if [ "$REAL_INTEGRITY_COUNT" -lt 50 ]; then
    echo "⚠️  WARNING: Expected more integrity hashes (found only $REAL_INTEGRITY_COUNT)"
else
    echo "✅ Sufficient integrity hashes found"
fi

# Show sample of real hashes
echo ""
echo "Sample real integrity hashes:"
grep '"integrity": "sha' package-lock.json | head -5
echo ""

# Step 6: Test the lockfile
echo "🧪 Step 6: Testing the lockfile..."
rm -rf node_modules
npm ci
echo "✅ npm ci succeeded"
echo ""

# Step 7: Test build
echo "🏗️  Step 7: Testing build..."
npm run build
echo "✅ Build succeeded"
echo ""

# Clean up node_modules before committing
rm -rf node_modules

echo "======================================"
echo "✅ LOCKFILE FIX COMPLETED SUCCESSFULLY"
echo "======================================"
echo ""
echo "Summary:"
echo "  ✓ Removed all placeholder hashes"
echo "  ✓ Generated real SHA-512 integrity hashes"
echo "  ✓ Verified with npm ci"
echo "  ✓ Tested build process"
echo "  ✓ Ready to commit"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff package-lock.json"
echo "  2. Commit: git add package-lock.json && git commit -m '🔧 Fix: Regenerate lockfile with real integrity hashes'"
echo "  3. Push: git push"
echo ""
