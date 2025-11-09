# Whop Creator MVP

Creator economy MVP built with TypeScript/React for Whop, deployed on Cloudflare Pages via GitHub Actions.

[![Deploy to Cloudflare Pages](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/deploy.yml/badge.svg)](https://github.com/ckorhonen/whop-creator-mvp/actions/workflows/deploy.yml)

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

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build Tool**: Vite
- **Deployment**: Cloudflare Pages (via GitHub Actions)
- **Platform**: Whop SDK
- **CI/CD**: GitHub Actions

## 📦 Project Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml   # Automated deployment workflow
├── src/
│   ├── App.tsx          # Main app component
│   ├── main.tsx         # Entry point
│   └── index.css        # Global styles
├── vite.config.ts       # Vite configuration
├── tsconfig.json        # TypeScript config
└── package.json         # Dependencies
```

## 🔧 Configuration

### GitHub Actions Deployment (Recommended)

The repository includes an automated deployment workflow that deploys to Cloudflare Pages on every push to the `main` branch.

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

- ✅ **Smart dependency installation** with package-lock.json support
- ✅ **TypeScript type checking** before build
- ✅ **Build verification** to ensure output is valid
- ✅ **Conditional deployment** based on secret availability
- ✅ **Detailed logging** for easy troubleshooting
- ✅ **Node.js 20** with npm caching for faster builds

## 🐛 Troubleshooting

If deployment fails, check:

1. **GitHub Secrets**: Ensure both `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are configured
2. **Build Logs**: Review the Actions tab for detailed error messages
3. **TypeScript Errors**: Check the "Type Check" step output
4. **Cloudflare Project**: Verify the project name in deploy.yml matches your Cloudflare Pages project

For detailed troubleshooting information, see [DEPLOYMENT_ANALYSIS.md](./DEPLOYMENT_ANALYSIS.md).

### Common Issues

**"package-lock.json not found" warning**  
→ Run `npm install` locally and commit the generated `package-lock.json`

**"Cloudflare secrets not configured" message**  
→ Add the required secrets in GitHub repository settings (see Configuration section above)

**Build fails with TypeScript errors**  
→ Check the type check output and fix errors in your code

## 🌟 Features

- ✨ TypeScript for type safety
- ⚛️ React 18 with modern hooks
- 🚀 Optimized for Cloudflare Pages edge deployment
- 🔗 Whop SDK integration ready
- ⚡ Fast builds with Vite
- 🤖 Automated CI/CD with GitHub Actions
- 📦 Dependency locking with package-lock.json

## 📊 Project Status

- ✅ Build pipeline: Configured and working
- ✅ Type checking: Enabled
- ✅ Dependency management: Locked with package-lock.json
- 🔄 Deployment: Requires Cloudflare secrets configuration

## 📄 License

MIT
