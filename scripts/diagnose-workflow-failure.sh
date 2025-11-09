#!/bin/bash

# Diagnostic script for regenerate-lockfile workflow failures
# Run this locally to test the workflow steps before running in GitHub Actions

set -e

echo "=== Workflow Failure Diagnostic Tool ==="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check 1: Node and npm versions
echo "=== Check 1: Node.js and npm versions ==="
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js installed: $NODE_VERSION"
else
    error "Node.js not found"
    exit 1
fi

if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    success "npm installed: $NPM_VERSION"
else
    error "npm not found"
    exit 1
fi
echo ""

# Check 2: npm registry connectivity
echo "=== Check 2: npm registry connectivity ==="
npm config set registry https://registry.npmjs.org/
if npm ping; then
    success "npm registry is accessible"
else
    warning "npm registry ping failed - may cause issues"
fi
echo ""

# Check 3: package.json validity
echo "=== Check 3: package.json validation ==="
if [ -f package.json ]; then
    success "package.json exists"
    if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))"; then
        success "package.json is valid JSON"
    else
        error "package.json is invalid JSON"
        exit 1
    fi
else
    error "package.json not found"
    exit 1
fi
echo ""

# Check 4: Existing lockfile status
echo "=== Check 4: Existing lockfile status ==="
if [ -f package-lock.json ]; then
    warning "Existing package-lock.json found"
    
    # Check for placeholder hashes
    if grep -q "example-integrity-hash\|example-.*-hash" package-lock.json; then
        error "Found placeholder integrity hashes in lockfile"
        PLACEHOLDER_COUNT=$(grep -c "example-.*-hash" package-lock.json || echo "0")
        echo "  Found $PLACEHOLDER_COUNT placeholder hashes"
    else
        success "No placeholder hashes detected"
    fi
    
    # Check for real integrity hashes
    if grep -q '"integrity": "sha' package-lock.json; then
        INTEGRITY_COUNT=$(grep -c '"integrity": "sha' package-lock.json || echo "0")
        success "Found $INTEGRITY_COUNT proper integrity hashes"
    else
        warning "No proper integrity hashes found"
    fi
else
    echo "  No existing package-lock.json (this is expected)"
fi
echo ""

# Check 5: Test lockfile generation
echo "=== Check 5: Test lockfile generation ==="
echo "This will attempt to generate a lockfile (dry run mode)..."

# Backup existing lockfile if present
if [ -f package-lock.json ]; then
    cp package-lock.json package-lock.json.backup
    echo "  Backed up existing lockfile"
fi

# Set npm config for reliability
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Attempt to generate lockfile
if npm install --package-lock-only --dry-run; then
    success "Dry run successful - lockfile generation should work"
else
    error "Dry run failed - there are issues with dependencies"
    
    # Restore backup if it exists
    if [ -f package-lock.json.backup ]; then
        mv package-lock.json.backup package-lock.json
        echo "  Restored backup lockfile"
    fi
    
    exit 1
fi
echo ""

# Check 6: Git configuration
echo "=== Check 6: Git configuration ==="
if command -v git &> /dev/null; then
    success "Git is installed"
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        success "Inside a Git repository"
        
        BRANCH=$(git branch --show-current)
        echo "  Current branch: $BRANCH"
        
        # Check if branch has upstream
        if git rev-parse --abbrev-ref @{upstream} > /dev/null 2>&1; then
            UPSTREAM=$(git rev-parse --abbrev-ref @{upstream})
            success "Branch has upstream: $UPSTREAM"
        else
            warning "Branch has no upstream configured"
        fi
    else
        error "Not inside a Git repository"
    fi
else
    error "Git not found"
fi
echo ""

# Summary
echo "=== Diagnostic Summary ==="
echo "If all checks passed, the workflow should succeed."
echo "If any checks failed, address those issues before running the workflow."
echo ""
echo "Common fixes:"
echo "  1. Network issues: Check firewall/proxy settings"
echo "  2. Dependency issues: Review package.json for version conflicts"
echo "  3. Git issues: Ensure proper branch setup and permissions"
echo ""

# Cleanup
if [ -f package-lock.json.backup ]; then
    rm package-lock.json.backup
fi

success "Diagnostic complete!"
