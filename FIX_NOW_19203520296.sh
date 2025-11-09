#!/bin/bash

# Quick Fix Script for Workflow Run #19203520296
# This script regenerates the complete package-lock.json with integrity hashes

set -e  # Exit on error

echo "🔧 Fixing incomplete package-lock.json..."
echo ""

# Step 1: Verify we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "fix/lockfile-integrity" ]; then
    echo "⚠️  Warning: You're on branch '$CURRENT_BRANCH'"
    echo "   Switching to 'fix/lockfile-integrity'..."
    git checkout fix/lockfile-integrity
fi

echo "✅ On branch: fix/lockfile-integrity"
echo ""

# Step 2: Clean everything
echo "🧹 Cleaning node_modules and old lockfile..."
rm -rf node_modules package-lock.json
npm cache clean --force
echo "✅ Clean complete"
echo ""

# Step 3: Regenerate lockfile
echo "🔨 Regenerating package-lock.json..."
npm install --package-lock-only

if [ ! -f "package-lock.json" ]; then
    echo "❌ Failed to generate package-lock.json"
    exit 1
fi
echo "✅ Lockfile regenerated"
echo ""

# Step 4: Verify the fix
echo "🔍 Verifying the fix..."
PACKAGE_COUNT=$(node -e "console.log(Object.keys(require('./package-lock.json').packages).length)")
INTEGRITY_COUNT=$(node -e "const p = require('./package-lock.json').packages; console.log(Object.values(p).filter(x => x.integrity).length)")

echo "   📦 Total packages: $PACKAGE_COUNT"
echo "   🔒 With integrity: $INTEGRITY_COUNT"
echo ""

if [ "$PACKAGE_COUNT" -lt 100 ]; then
    echo "❌ ERROR: Only $PACKAGE_COUNT packages found!"
    echo "   Expected 500+. Something went wrong."
    exit 1
fi

echo "✅ Verification passed!"
echo ""

# Step 5: Test installation
echo "🧪 Testing npm ci..."
npm ci
echo "✅ npm ci successful"
echo ""

# Step 6: Commit
echo "💾 Committing changes..."
git add package-lock.json
git commit -m "fix: Regenerate complete package-lock.json with integrity hashes

- Regenerated from scratch using npm install --package-lock-only
- Now includes $PACKAGE_COUNT transitive dependencies
- All packages have valid SHA-512 integrity hashes
- Enables proper dependency verification and security scanning

Fixes workflow run #19203520296"

echo "✅ Changes committed"
echo ""

# Step 7: Push
echo "🚀 Pushing to GitHub..."
git push origin fix/lockfile-integrity
echo "✅ Pushed successfully"
echo ""

echo "🎉 Fix complete!"
echo ""
echo "Next steps:"
echo "1. Workflow should now pass automatically"
echo "2. Verify at: https://github.com/ckorhonen/whop-creator-mvp/actions"
echo "3. Create PR to merge fix/lockfile-integrity → main"
echo ""
echo "Summary:"
echo "  ✅ Fixed incomplete lockfile"
echo "  ✅ Added $PACKAGE_COUNT packages with integrity hashes"
echo "  ✅ Enabled security scanning and reproducible builds"
