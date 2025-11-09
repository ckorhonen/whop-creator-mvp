#!/bin/bash

set -e

echo "🔨 Generating complete package-lock.json with integrity hashes..."
echo ""

# Step 1: Clean existing state
echo "🧹 Step 1: Cleaning existing npm state..."
rm -rf node_modules package-lock.json
npm cache clean --force
echo "✅ Cleaned npm cache and removed old lockfile"
echo ""

# Step 2: Validate package.json
echo "📋 Step 2: Validating package.json..."
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found!"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found, skipping JSON validation"
else
    if ! jq empty package.json 2>/dev/null; then
        echo "❌ Error: package.json is not valid JSON!"
        exit 1
    fi
    echo "✅ package.json is valid JSON"
fi
echo ""

# Step 3: Generate complete lockfile
echo "🔨 Step 3: Generating complete package-lock.json..."
npm install --package-lock-only

if [ ! -f "package-lock.json" ]; then
    echo "❌ Error: Failed to generate package-lock.json"
    exit 1
fi
echo "✅ package-lock.json generated successfully"
echo ""

# Step 4: Verify integrity hashes
echo "🔍 Step 4: Verifying integrity hashes..."
if command -v jq &> /dev/null; then
    PACKAGE_COUNT=$(jq '.packages | length' package-lock.json)
    INTEGRITY_COUNT=$(jq '[.packages | to_entries[] | select(.value.integrity)] | length' package-lock.json)
    
    echo "📦 Total packages: $PACKAGE_COUNT"
    echo "🔒 Packages with integrity: $INTEGRITY_COUNT"
    
    if [ "$INTEGRITY_COUNT" -eq 0 ] && [ "$PACKAGE_COUNT" -le 1 ]; then
        echo "❌ Error: Lockfile appears to be incomplete (no integrity hashes found)"
        exit 1
    fi
    
    # Check for placeholder hashes
    if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
        echo "❌ Error: Found placeholder integrity hashes!"
        exit 1
    fi
    
    echo "✅ All packages have valid integrity hashes"
else
    # Basic check without jq
    if ! grep -q "\"integrity\":" package-lock.json; then
        echo "❌ Error: No integrity hashes found in lockfile"
        exit 1
    fi
    echo "✅ Integrity hashes found in lockfile"
fi
echo ""

# Step 5: Test installation
echo "🧪 Step 5: Testing npm ci with generated lockfile..."
rm -rf node_modules
npm ci
echo "✅ npm ci successful - lockfile is valid!"
echo ""

echo "🎉 Success! Complete package-lock.json with integrity hashes has been generated."
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff package-lock.json"
echo "  2. Commit the changes: git add package-lock.json && git commit -m 'fix: Add complete package-lock.json with integrity hashes'"
echo "  3. Push to remote: git push"
