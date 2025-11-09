#!/bin/bash

echo "🔧 Generating package-lock.json with correct integrity hashes..."
echo ""

# Ensure we're in the repo root
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found in current directory"
    exit 1
fi

# Clean state
echo "🧹 Cleaning old state..."
rm -rf node_modules package-lock.json
npm cache clean --force

# Generate lockfile
echo ""
echo "📦 Generating package-lock.json from npm registry..."
npm install

# Verify the lockfile was created
if [ ! -f "package-lock.json" ]; then
    echo "❌ Error: package-lock.json was not generated"
    exit 1
fi

echo ""
echo "✅ package-lock.json generated successfully!"
echo ""

# Verify integrity hashes
echo "🔍 Verifying integrity hashes..."
PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json 2>/dev/null || echo "0")
INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json 2>/dev/null || echo "0")

if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
    echo "❌ Error: Found $PLACEHOLDER_COUNT placeholder integrity hashes!"
    echo "   The lockfile still contains invalid hashes."
    exit 1
fi

if [ "$INTEGRITY_COUNT" -lt 10 ]; then
    echo "⚠️  Warning: Only found $INTEGRITY_COUNT integrity hashes"
    echo "   Expected more packages with integrity hashes"
fi

echo "✅ Found $INTEGRITY_COUNT packages with valid integrity hashes"
echo "✅ No placeholder hashes detected"
echo ""

# Test installation
echo "🧪 Testing npm ci with generated lockfile..."
rm -rf node_modules
if npm ci; then
    echo "✅ npm ci successful!"
else
    echo "❌ npm ci failed!"
    exit 1
fi

echo ""
echo "🎉 Success! package-lock.json is ready to commit"
echo ""
echo "Next steps:"
echo "  git add package-lock.json"
echo "  git commit -m 'Generate package-lock.json with correct integrity hashes'"
echo "  git push"
