# Deployment Guide

## Cloudflare Pages Deployment

This project is deployed to Cloudflare Pages using GitHub Actions.

### Prerequisites

You need to set up the following GitHub Secrets in your repository settings:

1. **CLOUDFLARE_API_TOKEN**: Your Cloudflare API token with Pages deployment permissions
2. **CLOUDFLARE_ACCOUNT_ID**: Your Cloudflare account ID

### Setup Instructions

#### 1. Get Cloudflare API Token

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Navigate to: My Profile → API Tokens
3. Click "Create Token"
4. Use the "Edit Cloudflare Workers" template or create a custom token with these permissions:
   - Account - Cloudflare Pages - Edit
5. Copy the token and add it to GitHub Secrets as `CLOUDFLARE_API_TOKEN`

#### 2. Get Cloudflare Account ID

1. In the Cloudflare Dashboard, select your account
2. The Account ID is shown in the URL: `dash.cloudflare.com/{ACCOUNT_ID}/`
3. Or find it in the sidebar under "Overview"
4. Add it to GitHub Secrets as `CLOUDFLARE_ACCOUNT_ID`

### Workflow Configuration

The deployment workflow (`.github/workflows/deploy.yml`) runs on:
- Every push to the `main` branch
- Manual trigger via "workflow_dispatch"

### Deployment Process

1. **Checkout code**: Uses `actions/checkout@v4`
2. **Setup Node.js**: Installs Node.js v20
3. **Install dependencies**: Runs `npm install`
4. **Build**: Runs `npm run build` to create the production build
5. **Deploy**: Uses Wrangler to deploy the `dist` folder to Cloudflare Pages

### Common Issues & Solutions

#### Issue 1: Missing Secrets
**Error**: "Error: Unable to find API token"
**Solution**: Ensure both `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set in GitHub repository secrets

#### Issue 2: Build Fails
**Error**: Build step fails with TypeScript errors
**Solution**: Run `npm run build` locally to identify and fix TypeScript issues

#### Issue 3: Dependency Installation Fails
**Error**: npm install fails
**Solution**: 
- Verify `package.json` is valid JSON
- Check that all dependencies are available on npm
- Consider adding a `package-lock.json` by running `npm install` locally and committing the file

#### Issue 4: Wrangler Configuration
**Error**: "No such file or directory: wrangler.toml"
**Solution**: Wrangler doesn't need wrangler.toml for Pages deployments via CLI. The configuration is handled by command-line arguments.

### Manual Deployment

To deploy manually from your local machine:

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Deploy to Cloudflare Pages (requires wrangler auth)
npm run deploy
```

### Environment Variables

If your application needs environment variables:
1. Go to Cloudflare Dashboard → Pages → Your Project
2. Navigate to Settings → Environment Variables
3. Add variables for Production and/or Preview environments

Required environment variables (set in Cloudflare Dashboard):
- `WHOP_API_KEY`: Your Whop API key
- `WHOP_APP_ID`: Your Whop application ID

### Monitoring

- View deployment status: [Actions tab](https://github.com/ckorhonen/whop-creator-mvp/actions)
- View live site: Check Cloudflare Pages dashboard for your deployment URL
- View logs: Click on any workflow run in GitHub Actions

### Troubleshooting Checklist

- [ ] GitHub Secrets are configured correctly
- [ ] `package.json` has a valid `build` script
- [ ] Local build succeeds (`npm run build`)
- [ ] `wrangler.toml` is properly configured (optional for Pages)
- [ ] Cloudflare API token has correct permissions
- [ ] Project name matches in workflow: `whop-creator-mvp`
