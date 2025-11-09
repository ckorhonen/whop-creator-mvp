#!/bin/bash
set -e

echo "=== Fixing package-lock.json with valid integrity hashes ==="

# Remove the incomplete lockfile
if [ -f package-lock.json ]; then
    echo "Removing incomplete package-lock.json with placeholder hashes..."
    rm package-lock.json
fi

# Regenerate with npm
echo "Regenerating package-lock.json from npm registry..."
npm install --package-lock-only

# Verify it has proper integrity hashes
if grep -q "example-.*-hash" package-lock.json; then
    echo "❌ ERROR: Generated lockfile still contains placeholder hashes!"
    exit 1
fi

echo "✅ Successfully generated package-lock.json with valid integrity hashes"
echo "Total packages with integrity hashes: $(grep -c '"integrity": "sha' package-lock.json || echo '0')"
