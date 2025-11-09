#!/bin/bash

# Fix Lockfile with Real Integrity Hashes
# This script regenerates package-lock.json with proper SHA-512 hashes

set -e

echo "=========================================="
echo "🔧 Fixing package-lock.json"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this from the repository root."
    exit 1
fi

# Step 1: Remove the invalid lockfile
echo "Step 1: Removing invalid lockfile with placeholder hashes..."
if [ -f "package-lock.json" ]; then
    # Check for placeholder hashes
    if grep -q "example-.*-hash" package-lock.json; then
        PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
        echo "⚠️  Found $PLACEHOLDER_COUNT placeholder integrity hashes"
    fi
    
    rm package-lock.json
    echo "✅ Removed invalid lockfile"
else
    echo "ℹ️  No existing lockfile found"
fi
echo ""

# Step 2: Generate new lockfile with real hashes
echo "Step 2: Generating complete lockfile with real integrity hashes..."
echo "This will download and verify all dependencies..."
echo ""

npm install --package-lock-only

echo ""
echo "✅ Generated new package-lock.json"
echo ""

# Step 3: Verify the new lockfile
echo "Step 3: Verifying new lockfile..."
if [ -f "package-lock.json" ]; then
    LOCKFILE_LINES=$(wc -l < package-lock.json)
    echo "📊 Lockfile has $LOCKFILE_LINES lines"
    
    # Check for placeholder hashes (should be NONE)
    if grep -q "example-.*-hash" package-lock.json; then
        echo "❌ ERROR: Generated lockfile STILL contains placeholder hashes!"
        echo "This should not happen. Showing problematic entries:"
        grep -n "example-.*-hash" package-lock.json | head -10
        exit 1
    else
        echo "✅ No placeholder hashes found"
    fi
    
    # Check for real integrity hashes
    if grep -q '"integrity": "sha' package-lock.json; then
        INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
        echo "✅ Found $INTEGRITY_COUNT proper SHA integrity hashes"
    else
        echo "⚠️  Warning: No integrity hashes found in lockfile"
    fi
    
    # Check total packages
    PACKAGE_COUNT=$(grep -c '"resolved":' package-lock.json || echo "0")
    echo "📦 Total packages: $PACKAGE_COUNT"
    
    # Check file size
    FILE_SIZE=$(du -h package-lock.json | cut -f1)
    echo "💾 File size: $FILE_SIZE"
else
    echo "❌ Failed to generate lockfile"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ SUCCESS! Lockfile fixed"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff package-lock.json"
echo "2. Commit the changes: git add package-lock.json && git commit -m '🔧 Regenerate complete package-lock.json with real integrity hashes'"
echo "3. Push to GitHub: git push"
echo ""
