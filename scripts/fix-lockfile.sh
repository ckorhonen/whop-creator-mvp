#!/bin/bash
set -e

echo "🔧 Fixing incomplete package-lock.json..."
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Run this from the project root."
    exit 1
fi

# Display current lockfile status
echo "📊 Current lockfile status:"
if [ -f "package-lock.json" ]; then
    PACKAGE_COUNT=$(node -e "const pkg = require('./package-lock.json'); console.log(Object.keys(pkg.packages || {}).length)")
    echo "  - Packages in lockfile: $PACKAGE_COUNT"
else
    echo "  - No lockfile found"
fi
echo ""

# Clean up
echo "🧹 Cleaning up..."
rm -rf node_modules package-lock.json
npm cache clean --force
echo "✅ Cleanup complete"
echo ""

# Regenerate lockfile
echo "🔨 Regenerating complete package-lock.json..."
npm install --package-lock-only
echo "✅ Lockfile regenerated"
echo ""

# Verify the result
echo "🔍 Verifying regenerated lockfile..."
if [ ! -f "package-lock.json" ]; then
    echo "❌ Error: Failed to generate package-lock.json"
    exit 1
fi

PACKAGE_COUNT=$(node -e "const pkg = require('./package-lock.json'); console.log(Object.keys(pkg.packages || {}).length)")
INTEGRITY_COUNT=$(node -e "const pkg = require('./package-lock.json'); const packages = pkg.packages || {}; const withIntegrity = Object.values(packages).filter(p => p.integrity); console.log(withIntegrity.length)")

echo "✅ Lockfile verification:"
echo "  - Total packages: $PACKAGE_COUNT"
echo "  - Packages with integrity: $INTEGRITY_COUNT"
echo ""

if [ "$PACKAGE_COUNT" -le 1 ]; then
    echo "⚠️  Warning: Lockfile still appears incomplete (only $PACKAGE_COUNT package)"
    exit 1
fi

# Test installation
echo "🧪 Testing npm ci with regenerated lockfile..."
rm -rf node_modules
npm ci > /dev/null 2>&1
echo "✅ npm ci successful"
echo ""

echo "🎉 Lockfile fix complete!"
echo ""
echo "📝 Summary:"
echo "  - Total packages resolved: $PACKAGE_COUNT"
echo "  - Packages with integrity hashes: $INTEGRITY_COUNT"
echo "  - Ready for commit and push"
