# 🚀 Setup Instructions for Deployment

## ✅ What I've Already Fixed

I've updated the GitHub Actions workflow with the following improvements:

1. **Better Error Handling**: The workflow now validates configuration before attempting deployment
2. **Secret Validation**: Checks for required Cloudflare secrets upfront with clear error messages
3. **Build Verification**: Confirms the build output exists before deploying
4. **Smart Dependency Installation**: Handles both with and without package-lock.json
5. **Corrected Workflow Name**: Changed from "Cloudflare Workers" to "Cloudflare Pages"

## 🔴 What Still Needs to Be Done

The deployment will fail with clear error messages until you complete these steps:

### Step 1: Configure GitHub Secrets (REQUIRED)

The workflow **will fail at the "Check GitHub Secrets" step** until you add these:

1. Go to: https://github.com/ckorhonen/whop-creator-mvp/settings/secrets/actions

2. Add **CLOUDFLARE_API_TOKEN**:
   - Click "New repository secret"
   - Name: `CLOUDFLARE_API_TOKEN`
   - Get the value:
     - Go to https://dash.cloudflare.com/profile/api-tokens
     - Click "Create Token"
     - Use template: "Edit Cloudflare Workers" OR create custom token
     - Required permission: `Account.Cloudflare Pages` - Edit
     - Copy the token (shown only once!)
   - Paste the token value and save

3. Add **CLOUDFLARE_ACCOUNT_ID**:
   - Click "New repository secret"  
   - Name: `CLOUDFLARE_ACCOUNT_ID`
   - Get the value:
     - Go to https://dash.cloudflare.com/
     - Your Account ID is in the URL or sidebar
     - Format: `dash.cloudflare.com/<ACCOUNT_ID>/...`
   - Paste the Account ID and save

### Step 2: Create Cloudflare Pages Project (REQUIRED)

Choose ONE method:

#### Option A: Via Cloudflare Dashboard (Easiest)
1. Go to https://dash.cloudflare.com/
2. Navigate to **Workers & Pages**
3. Click **Create application** → **Pages** → **Upload assets**
4. Name: `whop-creator-mvp` (must match exactly)
5. Upload any dummy file to create the project

#### Option B: Via Wrangler CLI
```bash
npm install -g wrangler
wrangler login
wrangler pages project create whop-creator-mvp
```

#### Option C: Automatic Creation
The workflow *might* create it automatically, but this requires valid secrets first (Step 1).

### Step 3: Generate package-lock.json (RECOMMENDED)

This ensures reproducible builds:

```bash
# Clone the repo if you haven't
git clone https://github.com/ckorhonen/whop-creator-mvp.git
cd whop-creator-mvp

# Install dependencies to generate lock file
npm install

# Commit and push
git add package-lock.json
git commit -m "Add package-lock.json for reproducible builds"
git push origin main
```

**Note**: The workflow will work without this, but it's best practice to have it.

## 🎯 Testing the Deployment

After completing Steps 1 and 2 (Step 3 is optional):

### Automatic Trigger
The workflow runs automatically on every push to `main`. Just push any commit:
```bash
git commit --allow-empty -m "Trigger deployment"
git push origin main
```

### Manual Trigger
1. Go to https://github.com/ckorhonen/whop-creator-mvp/actions
2. Click "Deploy to Cloudflare Pages"
3. Click "Run workflow" → "Run workflow"

## 📊 Understanding Workflow Results

### ✅ If Secrets Are Configured Correctly:
You'll see:
- ✅ Validate Environment (passes)
- ✅ Check GitHub Secrets (passes)
- ✅ Install dependencies (passes)
- ✅ Build (passes)
- ✅ Verify Build Output (passes)
- ✅ Deploy to Cloudflare Pages (should pass if project exists)

### ❌ If Secrets Are Missing:
The workflow will **fail at "Check GitHub Secrets"** with a clear message:
```
❌ Error: CLOUDFLARE_API_TOKEN secret is not set
Please add it in Settings → Secrets and variables → Actions
```

### ❌ If Cloudflare Project Doesn't Exist:
The workflow will **fail at "Deploy to Cloudflare Pages"** with an error like:
```
Project not found: whop-creator-mvp
```

## 🐛 Troubleshooting Common Issues

### "CLOUDFLARE_API_TOKEN secret is not set"
**Solution**: Complete Step 1 above

### "CLOUDFLARE_ACCOUNT_ID secret is not set"  
**Solution**: Complete Step 1 above

### "Project not found: whop-creator-mvp"
**Solution**: Complete Step 2 above

### "Authentication error"
**Solutions**:
- Regenerate your API token with correct permissions
- Ensure token has `Account.Cloudflare Pages - Edit` permission
- Update the CLOUDFLARE_API_TOKEN secret with the new token

### "dist directory not found"
**Solutions**:
- Check TypeScript compilation errors in the Build step
- Verify all dependencies installed correctly
- This usually indicates a build failure - check previous steps

## ✨ After Successful Deployment

Once everything is configured, you'll see:
- ✅ Green checkmark in GitHub Actions
- 🌐 Deployment URL in the workflow logs
- 🎉 Your site live at: `https://whop-creator-mvp.pages.dev`

## 📋 Quick Checklist

Before deployment will succeed:
- [ ] CLOUDFLARE_API_TOKEN secret added in GitHub
- [ ] CLOUDFLARE_ACCOUNT_ID secret added in GitHub  
- [ ] Cloudflare Pages project `whop-creator-mvp` created
- [ ] Workflow re-run or new commit pushed

Optional but recommended:
- [ ] package-lock.json generated and committed

## 🔗 Helpful Links

- [Repository Settings](https://github.com/ckorhonen/whop-creator-mvp/settings)
- [GitHub Actions](https://github.com/ckorhonen/whop-creator-mvp/actions)
- [GitHub Secrets](https://github.com/ckorhonen/whop-creator-mvp/settings/secrets/actions)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)

---

**Questions?** Check the logs in GitHub Actions for specific error messages, or refer to DEPLOYMENT_TROUBLESHOOTING.md for more detailed troubleshooting steps.
