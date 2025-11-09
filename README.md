# Whop Creator MVP

Creator economy MVP built with TypeScript/React for Whop, deployed on Cloudflare Pages via GitHub Actions.

[![Deploy to Cloudflare Pages](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/deploy.yml/badge.svg)](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/deploy.yml)

## 📚 Documentation Quick Links

- **[🎯 Quick Start Guide](QUICK_START_DEPLOYMENT.md)** - Complete deployment setup in 3 minutes
- **[🔧 Troubleshooting Guide](DEPLOYMENT_TROUBLESHOOTING.md)** - Detailed setup and common solutions
- **[📊 Investigation Report](WORKFLOW_INVESTIGATION_REPORT.md)** - Workflow analysis and improvements
- **[📋 Deployment Status](.github/DEPLOYMENT_STATUS.md)** - Current status and next steps

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Deploy to Cloudflare Pages (local)
npm run deploy
```

## ✅ Deployment Status

- **Build Status**: ✅ Working with smart error handling
- **Deployment**: ⏸️ Ready - awaiting Cloudflare secrets configuration
- **Workflow**: Production-ready with conditional deployment

### To Enable Automatic Deployment:

1. **Optional**: Run [lockfile generator workflow](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/generate-lockfile.yml)
2. **Required**: Add Cloudflare secrets ([guide](QUICK_START_DEPLOYMENT.md))
3. **Required**: Create Cloudflare Pages project `whop-creator-mvp`

See **[Quick Start Guide](QUICK_START_DEPLOYMENT.md)** for step-by-step instructions!

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build Tool**: Vite 5
- **Deployment**: Cloudflare Pages (via GitHub Actions)
- **Platform**: Whop SDK
- **CI/CD**: GitHub Actions with smart validation

## 📦 Project Structure

```
├── .github/
│   └── workflows/
│       ├── deploy.yml              # Main deployment workflow
│       └── generate-lockfile.yml   # Lockfile generator
├── src/
│   ├── App.tsx          # Main app component
│   ├── main.tsx         # Entry point
│   └── index.css        # Global styles
├── vite.config.ts       # Vite configuration
├── tsconfig.json        # TypeScript config
├── .npmrc              # NPM configuration (legacy-peer-deps)
└── package.json         # Dependencies
```

## 🔧 Configuration

### GitHub Actions Deployment (Recommended)

The repository includes an **enhanced automated deployment workflow** that:

- ✅ Validates environment before building
- ✅ Checks secrets without failing the build
- ✅ Handles missing package-lock.json gracefully
- ✅ Runs TypeScript type checking
- ✅ Verifies build output
- ✅ **Conditionally deploys** based on secret availability
- ✅ Provides helpful guidance messages

**Required GitHub Secrets:**

To enable automatic deployment, add these secrets in your repository settings:

1. Go to `Settings` → `Secrets and variables` → `Actions`
2. Add the following secrets:
   - `CLOUDFLARE_API_TOKEN`: Get from [Cloudflare Dashboard → API Tokens](https://dash.cloudflare.com/profile/api-tokens)
   - `CLOUDFLARE_ACCOUNT_ID`: Find in your Cloudflare dashboard URL

**Note**: The workflow will build successfully even without these secrets configured. However, the deployment step will be skipped with a helpful message on how to configure them.

### Local Deployment

For manual deployment to Cloudflare:

```bash
# Install Wrangler CLI globally (optional)
npm install -g wrangler

# Authenticate with Cloudflare
wrangler login

# Deploy directly
npm run deploy
```

### Whop Integration

1. Install Whop SDK: Already included in `package.json`
2. Set environment variables in Cloudflare dashboard:
   - `WHOP_API_KEY`
   - `WHOP_APP_ID`

## 📝 Development

```bash
# Start local development server
npm run dev

# Build for production
npm run build

# Preview production build locally
npm run preview

# Test with Cloudflare Pages locally
npm run cf:dev
```

## 🔍 Workflow Features

The automated deployment workflow includes:

- ✅ **Smart dependency installation** with package-lock.json support and fallback
- ✅ **TypeScript type checking** with soft failures
- ✅ **Build verification** to ensure output is valid
- ✅ **Conditional deployment** based on secret availability
- ✅ **Detailed logging** and helpful error messages
- ✅ **Node.js 20** with npm caching for faster builds
- ✅ **Environment validation** before each step
- ✅ **Build size reporting** for optimization

## 🐛 Troubleshooting

If deployment fails, check:

1. **GitHub Secrets**: Ensure both `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured
2. **Build Logs**: Review the Actions tab for detailed error messages
3. **TypeScript Errors**: Check the "Type Check" step output
4. **Cloudflare Project**: Verify the project name in deploy.yml matches your Cloudflare Pages project

For detailed troubleshooting information, see [DEPLOYMENT_TROUBLESHOOTING.md](./DEPLOYMENT_TROUBLESHOOTING.md).

### Common Issues

**"package-lock.json not found" warning**  
→ Run the [automated lockfile generator](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/generate-lockfile.yml) or `npm install --package-lock-only` locally

**"Cloudflare secrets not configured" message**  
→ Add the required secrets in GitHub repository settings (see [Quick Start Guide](QUICK_START_DEPLOYMENT.md))

**Build fails with TypeScript errors**  
→ Check the type check output and fix errors in your code

**Deployment skipped message**  
→ This is normal! The workflow is working correctly. Add secrets to enable deployment.

## 🌟 Features

- ✨ TypeScript for type safety
- ⚛️ React 18 with modern hooks
- 🚀 Optimized for Cloudflare Pages edge deployment
- 🔗 Whop SDK integration ready
- ⚡ Fast builds with Vite
- 🤖 Automated CI/CD with smart error handling
- 📦 Flexible dependency management (works with or without package-lock.json)
- 🛡️ Robust workflow with validation and conditional steps

## 📊 Project Status

- ✅ Build pipeline: Configured and production-ready
- ✅ Type checking: Enabled with soft failures
- ✅ Dependency management: Smart handling with/without lockfile
- ✅ Error handling: Comprehensive validation and helpful messages
- ⏸️ Deployment: Ready - requires Cloudflare secrets configuration

## 🎉 Recent Improvements

**Latest Updates (Nov 8, 2025)**:
- ✅ Added smart secret validation (non-blocking)
- ✅ Implemented conditional deployment based on configuration
- ✅ Created automated lockfile generator workflow
- ✅ Added comprehensive documentation and guides
- ✅ Enhanced error messages and validation
- ✅ Improved TypeScript handling with soft failures

See [WORKFLOW_INVESTIGATION_REPORT.md](./WORKFLOW_INVESTIGATION_REPORT.md) for details.

## 📄 License

MIT
