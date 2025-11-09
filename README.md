# Whop Creator MVP

Creator economy MVP built with TypeScript/React for Whop, deployed on Cloudflare Workers.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Deploy to Cloudflare Workers
npm run deploy
```

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build Tool**: Vite
- **Deployment**: Cloudflare Workers (Pages)
- **Platform**: Whop SDK

## 📦 Project Structure

```
├── src/
│   ├── App.tsx          # Main app component
│   ├── main.tsx         # Entry point
│   └── index.css        # Global styles
├── wrangler.toml        # Cloudflare Workers config
├── vite.config.ts       # Vite configuration
└── package.json         # Dependencies
```

## 🔧 Configuration

### Whop Integration

1. Install Whop SDK: Already included in `package.json`
2. Set environment variables in Cloudflare dashboard:
   - `WHOP_API_KEY`
   - `WHOP_APP_ID`

### Cloudflare Workers Deployment

1. Install Wrangler CLI: `npm install -g wrangler`
2. Authenticate: `wrangler login`
3. Deploy: `npm run deploy`

## 📝 Development

- Local dev server: `npm run dev`
- Preview production build: `npm run preview`
- Test with Cloudflare Workers locally: `npm run cf:dev`

## 🌟 Features

- TypeScript for type safety
- React 18 with modern hooks
- Optimized for Cloudflare Workers edge deployment
- Whop SDK integration ready
- Fast builds with Vite

## 📄 License

MIT