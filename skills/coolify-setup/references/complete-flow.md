# CI/CD Setup: GitHub Actions

Automated builds on push to `main`. Use for projects with collaborators or zero-touch deploys.

## Setup

1. Copy workflow:
   ```bash
   mkdir -p .github/workflows
   cp <skill-path>/assets/deploy.yml .github/workflows/deploy.yml
   ```

2. Add webhook secret:
   ```bash
   gh secret set COOLIFY_WEBHOOK_URL --body "<webhook-url>"
   ```

3. Commit and push:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "ci: add deploy workflow"
   git push
   ```

## Flow

```
Push to main → GitHub Actions builds (deploy/Dockerfile) → Push to ghcr.io → Webhook → Coolify pulls image
```

## Structure After Setup

```
project/
├── .github/workflows/deploy.yml
├── deploy/
│   ├── Dockerfile
│   ├── deploy.sh
│   ├── .env.deploy.example
│   └── .env.deploy
└── ...
```

## Secrets

| Secret | Source |
|--------|--------|
| `GITHUB_TOKEN` | Automatic |
| `COOLIFY_WEBHOOK_URL` | Coolify → App → Webhooks |
