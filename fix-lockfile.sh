#!/bin/bash
set -e

echo "🔧 Fixing incomplete package-lock.json..."
echo ""

# Remove incomplete lockfile and node_modules
echo "📦 Cleaning existing files..."
rm -f package-lock.json
rm -rf node_modules

# Clean npm cache to ensure fresh install
echo "🧹 Cleaning npm cache..."
npm cache clean --force

# Generate complete lockfile with all dependencies
echo "🔨 Generating complete package-lock.json..."
npm install

# Verify the lockfile was created correctly
echo ""
echo "✅ Verifying package-lock.json..."

if [ ! -f "package-lock.json" ]; then
    echo "❌ Error: package-lock.json was not created!"
    exit 1
fi

# Count packages with integrity hashes
PACKAGE_COUNT=$(node -e "console.log(Object.keys(require('./package-lock.json').packages).length)")
INTEGRITY_COUNT=$(node -e "console.log(Object.values(require('./package-lock.json').packages).filter(p => p.integrity).length)")

echo "📊 Lockfile statistics:"
echo "  - Total packages: $PACKAGE_COUNT"
echo "  - Packages with integrity: $INTEGRITY_COUNT"

if [ "$INTEGRITY_COUNT" -eq 0 ]; then
    echo "❌ Error: No packages have integrity hashes!"
    exit 1
fi

# Test that npm ci works with the new lockfile
echo ""
echo "🧪 Testing npm ci with new lockfile..."
rm -rf node_modules
npm ci

echo ""
echo "✅ Package-lock.json generated and verified successfully!"
echo "   Ready to commit."
