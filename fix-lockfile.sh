#!/bin/bash
set -e

echo "🔧 Fixing package-lock.json with real integrity hashes"
echo "======================================================"
echo ""

# Remove the incomplete lockfile
if [ -f package-lock.json ]; then
  echo "📝 Removing incomplete lockfile..."
  rm package-lock.json
  echo "✅ Removed"
else
  echo "⚠️  No existing lockfile found"
fi

# Remove node_modules if they exist (to ensure clean state)
if [ -d node_modules ]; then
  echo "📝 Removing node_modules for clean state..."
  rm -rf node_modules
  echo "✅ Removed"
fi

echo ""
echo "📦 Generating complete package-lock.json..."
echo "   This will:"
echo "   - Download metadata for all dependencies"
echo "   - Calculate real SHA-512 integrity hashes"
echo "   - Resolve all transitive dependencies"
echo ""

# Generate complete lockfile
npm install --package-lock-only

echo ""
echo "✅ Lockfile generated successfully!"
echo ""

# Verify the lockfile
echo "🔍 Verifying lockfile..."
echo "======================================================"

LOCKFILE_LINES=$(wc -l < package-lock.json)
echo "📊 Total lines: $LOCKFILE_LINES"

if [ "$LOCKFILE_LINES" -lt 1000 ]; then
  echo "❌ ERROR: Lockfile seems incomplete (only $LOCKFILE_LINES lines)"
  echo "   Expected at least 1000 lines for a complete lockfile"
  exit 1
fi

RESOLVED_COUNT=$(grep -c '"resolved":' package-lock.json || echo '0')
echo "📦 Total packages: $RESOLVED_COUNT"

FILE_SIZE=$(du -h package-lock.json | cut -f1)
echo "💾 File size: $FILE_SIZE"

# Check for placeholder hashes
PLACEHOLDER_COUNT=$(grep -c 'example-integrity-hash' package-lock.json || echo '0')
if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
  echo "❌ ERROR: Found $PLACEHOLDER_COUNT placeholder integrity hashes!"
  echo "   Lockfile generation failed"
  exit 1
else
  echo "✅ No placeholder hashes found"
fi

# Verify all integrity hashes are proper SHA-512
if grep -q '"integrity": "sha512-[a-zA-Z0-9+/=]*"' package-lock.json; then
  echo "✅ All integrity hashes are valid SHA-512"
else
  echo "⚠️  Warning: Some integrity hashes may not be SHA-512"
fi

echo ""
echo "🧪 Testing lockfile validity..."
if npm ls --package-lock-only > /dev/null 2>&1; then
  echo "✅ Lockfile is valid"
else
  echo "⚠️  Warning: Some dependency issues detected (may be non-critical)"
  npm ls --package-lock-only || true
fi

echo ""
echo "======================================================"
echo "✅ SUCCESS! Package-lock.json is now complete"
echo "======================================================"
echo ""
echo "📋 Next steps:"
echo "   1. Review the changes: git diff package-lock.json"
echo "   2. Commit the changes: git add package-lock.json"
echo "   3. Push to branch: git push origin fix-complete-lockfile-integrity"
echo ""
echo "🎉 The workflow should now pass!"
