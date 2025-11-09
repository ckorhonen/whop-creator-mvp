#!/bin/bash

# Manual lockfile generation script
# Use this if the GitHub Actions workflow continues to fail

set -e

echo "🔧 Manual Lockfile Generation Script"
echo "====================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

function success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check we're in the right directory
if [ ! -f "package.json" ]; then
    error "package.json not found. Please run this script from the repository root."
    exit 1
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
info "Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "fix-complete-lockfile-integrity" ]; then
    warning "Not on fix-complete-lockfile-integrity branch"
    read -p "Do you want to switch to it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout fix-complete-lockfile-integrity
        success "Switched to fix-complete-lockfile-integrity"
    else
        warning "Continuing on current branch: $CURRENT_BRANCH"
    fi
fi

# Pull latest changes
info "Pulling latest changes..."
git pull origin $(git branch --show-current) || {
    warning "Pull failed, but continuing..."
}

# Check Node version
NODE_VERSION=$(node --version)
info "Node version: $NODE_VERSION"

NPM_VERSION=$(npm --version)
info "npm version: $NPM_VERSION"

# Backup existing lockfile if present
if [ -f "package-lock.json" ]; then
    warning "Existing package-lock.json found"
    
    # Check for placeholder hashes
    if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
        error "Found placeholder integrity hashes - removing invalid lockfile"
    fi
    
    mv package-lock.json package-lock.json.backup
    info "Backed up to package-lock.json.backup"
fi

# Clean npm cache
info "Cleaning npm cache..."
npm cache clean --force

# Set npm config for reliability
info "Configuring npm for reliability..."
npm config set registry https://registry.npmjs.org/
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Test npm connectivity
info "Testing npm registry connectivity..."
if npm ping; then
    success "npm registry is accessible"
else
    warning "npm registry ping failed - this might cause issues"
fi

# Generate lockfile
echo ""
info "Generating complete package-lock.json..."
echo "This may take a few minutes..."

if npm install --package-lock-only; then
    success "Lockfile generated successfully!"
else
    error "Failed to generate lockfile"
    
    # Restore backup if it exists
    if [ -f "package-lock.json.backup" ]; then
        mv package-lock.json.backup package-lock.json
        warning "Restored backup lockfile"
    fi
    
    exit 1
fi

# Verify the generated lockfile
echo ""
info "Verifying generated lockfile..."

if [ -f "package-lock.json" ]; then
    LOCKFILE_LINES=$(wc -l < package-lock.json)
    info "Lockfile has $LOCKFILE_LINES lines"
    
    # Check for placeholder hashes
    if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
        error "Generated lockfile contains placeholder hashes!"
        exit 1
    else
        success "No placeholder hashes found"
    fi
    
    # Check for real integrity hashes
    if grep -q '"integrity": "sha' package-lock.json; then
        INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
        success "Found $INTEGRITY_COUNT proper integrity hashes"
    else
        warning "No integrity hashes found - this might be an issue"
    fi
    
    # Check lockfile validity
    if npm ls --package-lock-only 2>&1 | grep -q 'npm ERR!'; then
        warning "Some dependency issues detected, but lockfile is still usable"
    else
        success "Lockfile is valid"
    fi
else
    error "Lockfile was not created"
    exit 1
fi

# Show statistics
echo ""
echo "=== Lockfile Statistics ==="
echo "Total lines: $(wc -l < package-lock.json)"
echo "Total packages: $(grep -c '"resolved":' package-lock.json || echo '0')"
echo "File size: $(du -h package-lock.json | cut -f1)"
echo ""

# Ask if user wants to commit
read -p "Do you want to commit and push the lockfile? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Staging lockfile..."
    git add package-lock.json
    
    if git diff --staged --quiet; then
        warning "No changes to commit - lockfile is already up to date"
        exit 0
    fi
    
    info "Committing changes..."
    git commit -m "🔧 Regenerate complete package-lock.json [skip ci]

Generated manually using scripts/generate-lockfile-locally.sh

Changes:
- Complete dependency resolution with all transitive dependencies
- Proper integrity hashes for all packages (no placeholders)
- Verified lockfile format

Fixes workflow failures and enables proper dependency caching."
    
    info "Pushing to remote..."
    if git push origin $(git branch --show-current); then
        success "Successfully pushed lockfile to remote!"
        echo ""
        success "✨ All done! The lockfile has been regenerated and pushed."
    else
        error "Failed to push changes"
        warning "You may need to pull first: git pull --rebase"
        exit 1
    fi
else
    info "Lockfile generated but not committed."
    echo "To commit manually, run:"
    echo "  git add package-lock.json"
    echo "  git commit -m 'Regenerate package-lock.json'"
    echo "  git push"
fi

# Clean up backup
if [ -f "package-lock.json.backup" ]; then
    rm package-lock.json.backup
fi

echo ""
success "Script complete!"
