#!/bin/bash
set -e

echo "=================================="
echo "Regenerating package-lock.json"
echo "=================================="
echo ""

# Step 1: Remove old lockfile
if [ -f package-lock.json ]; then
    echo "✅ Removing old lockfile with placeholder hashes..."
    rm package-lock.json
fi

# Step 2: Remove node_modules if it exists
if [ -d node_modules ]; then
    echo "✅ Removing node_modules..."
    rm -rf node_modules
fi

# Step 3: Clear npm cache to ensure fresh downloads
echo "✅ Clearing npm cache..."
npm cache clean --force

# Step 4: Regenerate lockfile with real integrity hashes
echo ""
echo "📦 Regenerating lockfile with proper integrity hashes..."
echo "This will fetch fresh package metadata from npm registry..."
echo ""
npm install --package-lock-only --loglevel=info

# Step 5: Verify the lockfile
echo ""
echo "=================================="
echo "Verification"
echo "=================================="

if [ ! -f package-lock.json ]; then
    echo "❌ ERROR: Failed to generate lockfile!"
    exit 1
fi

# Check for placeholder hashes
PLACEHOLDERS=$(grep -c "example-.*-hash" package-lock.json 2>/dev/null || echo "0")

if [ "$PLACEHOLDERS" -gt "0" ]; then
    echo "❌ ERROR: Lockfile still contains $PLACEHOLDERS placeholder hashes!"
    echo ""
    echo "Examples found:"
    grep "example-.*-hash" package-lock.json | head -5
    exit 1
fi

# Count real integrity hashes
REAL_HASHES=$(grep -c '\"integrity\": \"sha' package-lock.json 2>/dev/null || echo "0")

if [ "$REAL_HASHES" -eq "0" ]; then
    echo "❌ ERROR: No integrity hashes found in lockfile!"
    exit 1
fi

echo "✅ SUCCESS! Lockfile regenerated with real integrity hashes"
echo ""
echo "Statistics:"
echo "  Total lines: $(wc -l < package-lock.json)"
echo "  Packages with integrity: $REAL_HASHES"
echo "  File size: $(du -h package-lock.json | cut -f1)"
echo ""
echo "You can now commit the updated package-lock.json"
