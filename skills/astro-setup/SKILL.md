---
name: astro-setup
description: Set up deployment for Astro static sites. Creates deploy/Dockerfile for Astro (bun + nginx) and delegates to coolify-setup for Coolify hosting, DNS, and first deploy.
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion
user-invocable: true
---

# Astro Setup

## Purpose

Scaffolds an Astro-specific Dockerfile and delegates all Coolify deployment setup to the `coolify-setup` skill. This skill only handles the Astro-specific part.

## Variables

SKILL_ASSETS: <absolute-path-to-this-skill>/assets

## Workflow

When invoked, follow these steps:

### Phase 1: Scaffold Astro Dockerfile

1. Create `deploy/` directory in project root if it does not exist
2. Copy `${SKILL_ASSETS}/Dockerfile` to `deploy/Dockerfile`
3. Tell user: "Created deploy/Dockerfile for Astro (bun build + nginx static serve, port 80)."

### Phase 2: Delegate to coolify-setup

Invoke the `coolify-setup` skill. It will handle:
- deploy/.env.deploy scaffolding
- deploy/deploy.sh scaffolding
- Coolify API setup (server, project, app with port auto-inferred from Dockerfile)
- Cloudflare DNS (optional)
- First deploy

## Assets

| Source | Destination |
|--------|-------------|
| `assets/Dockerfile` | `deploy/Dockerfile` |

## Dockerfile Details

The provided Dockerfile uses a two-stage build:
1. **Build stage**: `oven/bun:1-alpine` — installs deps, runs `bun run build`
2. **Serve stage**: `nginx:alpine` — copies `dist/` to nginx, exposes port 80

For SSR Astro projects or different runtimes, modify `deploy/Dockerfile` after setup.

## Prerequisites

Required: bun, docker, gh, jq, curl

## Report

After completing the skill, provide output following this format:

```md
## Astro Setup

**Project**: [repo name]
**Status**: ✅ Completed | ❌ Failed

**Result**:
- Dockerfile: deploy/Dockerfile (bun + nginx)
- Coolify: delegated to coolify-setup

**Next**: Run `bash deploy/deploy.sh` for future deploys.
```
