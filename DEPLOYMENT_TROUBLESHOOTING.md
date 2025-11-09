# 🔧 Deployment Troubleshooting Guide

## Current Status
The GitHub Actions workflow "Deploy to Cloudflare Workers" failed after 24 seconds.

## 🔍 Root Cause Analysis

Based on repository analysis, the following issues were identified:

### 1. Missing `package-lock.json`
- **Issue**: No lock file committed to repository
- **Impact**: Can cause dependency resolution issues in CI/CD
- **Severity**: Medium

### 2. GitHub Secrets Configuration
- **Issue**: Required Cloudflare secrets may not be configured
- **Impact**: Deployment will fail at the Cloudflare deployment step
- **Severity**: High

### 3. Cloudflare Pages Project
- **Issue**: Target project may not exist in Cloudflare account
- **Impact**: Deployment command will fail
- **Severity**: High

## ✅ Step-by-Step Fix Guide

### Step 1: Generate and Commit Lock File

```bash
# Navigate to your project directory
cd whop-creator-mvp

# Generate package-lock.json
npm install

# Verify the file was created
ls -la package-lock.json

# Commit and push
git add package-lock.json
git commit -m "Add package-lock.json for reproducible builds"
git push origin main
```

### Step 2: Configure GitHub Secrets

1. Go to your repository: https://github.com/ckorhonen/whop-creator-mvp
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

#### Required Secrets:

**Secret 1: CLOUDFLARE_API_TOKEN**
- **How to get it**:
  1. Go to https://dash.cloudflare.com/profile/api-tokens
  2. Click **Create Token**
  3. Use template: **Edit Cloudflare Workers** or create custom token
  4. Required permissions:
     - `Account.Cloudflare Pages` - Edit
  5. Copy the token (you'll only see it once!)
  6. Add as secret in GitHub

**Secret 2: CLOUDFLARE_ACCOUNT_ID**
- **How to get it**:
  1. Go to https://dash.cloudflare.com/
  2. Select any site or Workers/Pages
  3. Your Account ID is visible in:
     - The URL: `dash.cloudflare.com/<ACCOUNT_ID>/...`
     - The right sidebar under "Account ID"
  4. Copy and add as secret in GitHub

### Step 3: Create Cloudflare Pages Project

Choose **ONE** of the following methods:

#### Option A: Via Cloudflare Dashboard (Recommended)
1. Go to https://dash.cloudflare.com/
2. Navigate to **Workers & Pages**
3. Click **Create application** → **Pages** → **Upload assets**
4. Name the project: `whop-creator-mvp`
5. You can upload a dummy file just to create the project

#### Option B: Via Wrangler CLI
```bash
# Install wrangler globally (if not already installed)
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Create the Pages project
wrangler pages project create whop-creator-mvp

# Follow the prompts
```

#### Option C: Let the Workflow Create It
- The wrangler action should create the project automatically
- But this requires valid API token and account ID first

### Step 4: Verify Configuration

After completing Steps 1-3:

1. **Check GitHub Secrets**:
   - Go to Settings → Secrets and variables → Actions
   - Verify both secrets are listed (values are hidden)

2. **Check Cloudflare Project**:
   - Go to https://dash.cloudflare.com/
   - Navigate to Workers & Pages
   - Verify `whop-creator-mvp` project exists

3. **Verify package-lock.json**:
   - Check GitHub repo, should see the file in root directory

### Step 5: Trigger Deployment

Choose ONE option:

#### Option A: Push a New Commit
```bash
# Make any small change (or use --allow-empty)
git commit --allow-empty -m "Trigger deployment after configuration"
git push origin main
```

#### Option B: Manual Workflow Trigger
1. Go to https://github.com/ckorhonen/whop-creator-mvp/actions
2. Click on "Deploy to Cloudflare Workers" workflow
3. Click "Run workflow" → "Run workflow"

## 🚀 Workflow Improvements Applied

The deployment workflow has been updated with the following improvements:

### Changes Made:
1. ✅ **NPM Caching**: Added `cache: 'npm'` to speed up dependency installation
2. ✅ **Fallback Install**: `npm ci || npm install` - tries `npm ci` first, falls back to `npm install`
3. ✅ **Build Verification**: Added step to verify `dist` directory exists before deployment
4. ✅ **Better Logging**: Added directory listing to help debug build issues

### Workflow Steps:
```yaml
1. Checkout code
2. Setup Node.js 20 with npm caching
3. Install dependencies (with fallback)
4. Build project
5. Verify build output exists
6. Deploy to Cloudflare Pages
```

## 🐛 Common Errors and Solutions

### Error: "npm ci can only install packages with an existing package-lock.json"
**Solution**: The updated workflow handles this with `npm ci || npm install`

### Error: "Authentication error" or "Invalid API token"
**Solutions**:
- Verify `CLOUDFLARE_API_TOKEN` secret is set correctly
- Check token hasn't expired
- Ensure token has correct permissions
- Regenerate token if needed

### Error: "Project not found" or "whop-creator-mvp does not exist"
**Solutions**:
- Create the project first (see Step 3)
- Verify project name matches exactly: `whop-creator-mvp`
- Check you're using the correct Cloudflare account

### Error: "dist directory not found"
**Solutions**:
- Check the build command in package.json: `"build": "tsc && vite build"`
- Verify all dependencies are installed correctly
- Check for TypeScript compilation errors
- Look at the "Build" step logs in GitHub Actions

### Error: "Account ID is required"
**Solution**: Add `CLOUDFLARE_ACCOUNT_ID` secret (see Step 2)

## 📊 Verify Successful Deployment

After deployment succeeds, you should see:

1. ✅ Green checkmark in GitHub Actions
2. ✅ Deployment URL in workflow logs
3. ✅ Project visible in Cloudflare dashboard
4. ✅ Site accessible at: `whop-creator-mvp.pages.dev`

## 📞 Need More Help?

If issues persist after following this guide:

1. Check the detailed logs in GitHub Actions
2. Look for the specific error message
3. Check Cloudflare dashboard for any errors
4. Verify all secrets are set correctly (delete and recreate if unsure)

## 🎯 Quick Checklist

- [ ] package-lock.json committed and pushed
- [ ] CLOUDFLARE_API_TOKEN secret configured
- [ ] CLOUDFLARE_ACCOUNT_ID secret configured
- [ ] Cloudflare Pages project created
- [ ] Workflow re-run or new commit pushed
- [ ] Deployment successful
- [ ] Site accessible online

---
**Last Updated**: November 8, 2025
**Workflow Version**: v2 (with caching and error handling)
