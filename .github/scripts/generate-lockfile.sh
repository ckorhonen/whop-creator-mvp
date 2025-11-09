#!/bin/bash
set -e

echo "=== Package-lock.json Generation Script ==="
echo ""

# Clean state
echo "1. Cleaning existing lockfile and node_modules..."
rm -rf package-lock.json node_modules

# Configure npm for reliability
echo "2. Configuring npm..."
npm config set registry https://registry.npmjs.org/
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Generate lockfile
echo "3. Installing dependencies to generate complete lockfile..."
npm install

# Verify
echo "4. Verifying lockfile..."
if [ -f package-lock.json ]; then
    LINES=$(wc -l < package-lock.json)
    PACKAGES=$(grep -c '"resolved":' package-lock.json || echo "0")
    INTEGRITY=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
    
    echo "✅ Lockfile generated successfully!"
    echo "   - Lines: $LINES"
    echo "   - Packages: $PACKAGES"
    echo "   - Integrity hashes: $INTEGRITY"
    
    if [ "$LINES" -lt 1000 ]; then
        echo "⚠️  WARNING: Lockfile seems too small ($LINES lines)"
        exit 1
    fi
    
    if [ "$INTEGRITY" -lt 10 ]; then
        echo "❌ ERROR: Not enough integrity hashes found"
        exit 1
    fi
    
    echo ""
    echo "✅ Package-lock.json is complete and valid!"
else
    echo "❌ ERROR: Failed to generate package-lock.json"
    exit 1
fi
