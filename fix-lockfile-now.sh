#!/bin/bash
set -e

echo "🔧 Fixing package-lock.json integrity issue..."
echo ""

# Step 1: Remove incomplete lockfile and clean cache
echo "📝 Step 1: Cleaning npm state..."
rm -f package-lock.json
rm -rf node_modules
npm cache clean --force
echo "✅ Cleaned"
echo ""

# Step 2: Validate package.json
echo "📝 Step 2: Validating package.json..."
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found!"
    exit 1
fi

if ! node -e "JSON.parse(require('fs').readFileSync('package.json'))" 2>/dev/null; then
    echo "❌ Error: package.json is not valid JSON!"
    exit 1
fi
echo "✅ package.json is valid"
echo ""

# Step 3: Generate complete lockfile
echo "📝 Step 3: Generating complete package-lock.json..."
npm install --package-lock-only
echo "✅ Lockfile generated"
echo ""

# Step 4: Verify the result
echo "📝 Step 4: Verifying integrity..."
if [ ! -f "package-lock.json" ]; then
    echo "❌ Error: Failed to generate package-lock.json!"
    exit 1
fi

# Count packages with integrity hashes
if command -v jq &> /dev/null; then
    PACKAGE_COUNT=$(jq '.packages | length' package-lock.json)
    INTEGRITY_COUNT=$(jq '[.packages | to_entries[] | select(.value.integrity)] | length' package-lock.json)
    echo "📊 Total packages: $PACKAGE_COUNT"
    echo "📊 Packages with integrity: $INTEGRITY_COUNT"
else
    echo "📊 Lockfile size: $(wc -l < package-lock.json) lines"
fi

echo ""
echo "✅ package-lock.json has been successfully regenerated!"
echo ""
echo "Next steps:"
echo "1. Review the changes with: git diff package-lock.json"
echo "2. Test installation with: npm ci"
echo "3. Commit the changes: git add package-lock.json && git commit -m 'fix: Regenerate complete package-lock.json'"
echo "4. Push to remote: git push"
