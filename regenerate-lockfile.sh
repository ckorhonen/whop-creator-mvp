#!/bin/bash
set -e

echo "🔧 Lockfile Regeneration Script"
echo "================================"
echo ""

# Step 1: Remove incomplete lockfile and node_modules
echo "🗑️  Step 1: Cleaning up..."
rm -f package-lock.json
rm -rf node_modules
echo "   ✅ Removed incomplete lockfile and node_modules"
echo ""

# Step 2: Clear npm cache
echo "🧹 Step 2: Cleaning npm cache..."
npm cache clean --force
echo "   ✅ npm cache cleared"
echo ""

# Step 3: Configure npm
echo "⚙️  Step 3: Configuring npm..."
echo "legacy-peer-deps=true" > .npmrc
echo "   ✅ npm configured with legacy peer deps"
echo ""

# Step 4: Generate complete lockfile
echo "🔨 Step 4: Generating complete package-lock.json..."
echo "   This may take a few minutes..."
npm install --verbose
echo "   ✅ Lockfile generated!"
echo ""

# Step 5: Verify the lockfile
echo "🔍 Step 5: Verifying lockfile..."
if [ ! -f "package-lock.json" ]; then
    echo "   ❌ ERROR: package-lock.json was not generated!"
    exit 1
fi

LINES=$(wc -l < package-lock.json)
PACKAGES=$(jq '.packages | length' package-lock.json || echo "0")
INTEGRITY_COUNT=$(jq '[.packages | to_entries[] | select(.value.integrity)] | length' package-lock.json || echo "0")

echo "   📊 Stats:"
echo "      Lines: $LINES"
echo "      Total packages: $PACKAGES"
echo "      With integrity hashes: $INTEGRITY_COUNT"

if [ "$PACKAGES" -lt 100 ]; then
    echo "   ❌ ERROR: Lockfile appears incomplete (only $PACKAGES packages)"
    exit 1
fi

echo "   ✅ Lockfile appears complete"
echo ""

# Step 6: Test with npm ci
echo "🧪 Step 6: Testing with npm ci..."
rm -rf node_modules
npm ci
echo "   ✅ npm ci successful!"
echo ""

echo "🎉 SUCCESS! Complete package-lock.json has been generated"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff package-lock.json"
echo "  2. Commit the changes: git add package-lock.json .npmrc && git commit -m 'fix: regenerate complete package-lock.json'"
echo "  3. Push to remote: git push"
echo ""
