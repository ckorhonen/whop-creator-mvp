#!/bin/bash
# Script to regenerate package-lock.json with correct integrity hashes

set -e

echo "Regenerating package-lock.json..."

# Remove existing lockfile if it exists
if [ -f "package-lock.json" ]; then
    echo "Removing existing package-lock.json..."
    rm package-lock.json
fi

# Regenerate lockfile
echo "Running npm install to generate fresh lockfile..."
npm install --package-lock-only

echo "✓ package-lock.json has been regenerated successfully!"
echo "Please commit and push the changes."
