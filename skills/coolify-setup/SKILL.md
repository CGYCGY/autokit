---
name: coolify-setup
description: First-time setup of Coolify deployment for a Dockerized project. Use when user wants to configure Coolify hosting, optional Cloudflare DNS, and first deploy. Requires deploy/Dockerfile to exist. For ongoing operations on an already-deployed project (redeploy, logs, env updates), use the coolify skill.
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion
user-invocable: true
---

# Coolify Setup

## Purpose

First-time setup: scaffold deploy directory, create Coolify app, optional Cloudflare DNS, first deploy. Framework-agnostic. Requires `deploy/Dockerfile` in project root.

For already-deployed projects (where `COOLIFY_WEBHOOK_URL` is set in `deploy/.env.deploy`), this skill routes to a redeploy via `bash deploy/deploy.sh`. For all other ongoing operations, use the `coolify` skill.

## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools
SKILL_ASSETS: ${CLAUDE_SKILL_DIR}/assets
COOLIFY_TOOLS: ${CLAUDE_SKILL_DIR}/../coolify/tools
CLOUDFLARE_TOOLS: ${CLAUDE_SKILL_DIR}/../cloudflare/tools

## Workflow

### Phase 0: Precondition Check

1. Check `deploy/Dockerfile` exists in project root
2. If missing: **STOP** and tell user: "No deploy/Dockerfile found. Create one for your project in deploy/Dockerfile first, or use a framework-specific setup skill (e.g. astro-setup) that provides one."
3. Check `deploy/Dockerfile` has a `HEALTHCHECK` instruction. If missing:
   - Read the Dockerfile to understand the base image and app type
   - Add a `HEALTHCHECK` instruction. Use `wget` over `curl` — `wget` is available by default in alpine-based images, `curl` requires `apk add curl`
   - If the app serves HTTP (nginx, node, etc.), add a `/healthz` endpoint and use: `HEALTHCHECK --interval=60s --timeout=5s --start-period=10s --retries=3 CMD wget -qO /dev/null http://localhost/healthz || exit 1`
   - For nginx: also add a `location = /healthz { access_log off; return 200 "ok"; }` block to the nginx config
   - For non-HTTP apps: use an appropriate check (e.g. process check, TCP check)

### Phase 1: Scaffold Deploy Directory

1. Create `deploy/` directory if it does not exist
2. Copy `${SKILL_ASSETS}/.env.deploy.example` to `deploy/.env.deploy.example` if not present
3. Copy `${SKILL_ASSETS}/deploy.sh` to `deploy/deploy.sh` if not present, make executable (`chmod +x`)
4. If `deploy/.env.deploy` does not exist: copy from `deploy/.env.deploy.example`
5. Add `deploy/.env.deploy` to `.gitignore` if not already listed
6. Ask user: "Fill COOLIFY_BASE_URL, COOLIFY_API_TOKEN, COOLIFY_SERVER_UUID, COOLIFY_DEST_UUID in deploy/.env.deploy, then confirm."

### Phase 2: Detect Flow

1. Run `bash ${SKILL_TOOLS}/get-config.sh`, check `COOLIFY_WEBHOOK_URL`
2. If `COOLIFY_WEBHOOK_URL` is set and non-empty: project is already set up.
   - Run `bash deploy/deploy.sh` to redeploy
   - Tell user: "Already set up — triggered redeploy. For other operations (logs, env, status), use the coolify skill."
   - Go to Phase 6
3. If empty: continue to Phase 3.

### Phase 3: Coolify Setup (New Project)

1. Run `bash ${COOLIFY_TOOLS}/list-servers.sh`, parse output
2. Ask user to select server
3. Run `bash ${COOLIFY_TOOLS}/list-projects.sh`, parse output
4. Ask user: select existing project OR enter new project name
5. If new: run `bash ${COOLIFY_TOOLS}/create-project.sh <name>`, capture project UUID
6. Run `bash ${SKILL_TOOLS}/get-config.sh`, parse GITHUB_ORG and REPO_NAME
7. If GITHUB_ORG empty:
   - Try: `git remote get-url origin` → extract org from URL
   - If no remote: ask user
   - Lowercase the value before storing
   - Run `bash ${SKILL_TOOLS}/set-config.sh GITHUB_ORG <lowercase-value>`
8. If REPO_NAME empty:
   - Default: project directory name (basename of cwd)
   - Lowercase the value before storing
   - Run `bash ${SKILL_TOOLS}/set-config.sh REPO_NAME <lowercase-value>`
9. Set IMAGE=`ghcr.io/${GITHUB_ORG}/${REPO_NAME}` (both must be lowercase — GHCR requirement)
10. Ask user for app name, default to REPO_NAME
11. If the user specified an environment (e.g. "staging"), list environments with `curl -sf -H "Authorization: Bearer ${COOLIFY_API_TOKEN}" "${COOLIFY_BASE_URL}/api/v1/projects/<project-uuid>/environments"` and pass the environment name as 4th arg
12. Run `bash ${COOLIFY_TOOLS}/create-app.sh <project-uuid> <app-name> <IMAGE> [environment-name]`
    - Port is auto-inferred from deploy/Dockerfile EXPOSE directive

### Phase 3b: Set App Environment Variables

1. Add `.env.production` to `.gitignore` if not already listed
2. **If `.env.production` exists** (project root):
   - Run `bash ${COOLIFY_TOOLS}/set-envs.sh <COOLIFY_APP_UUID> .env.production`
   - Go to Phase 4
3. **If `.env.example` exists** (project root):
   - Copy `.env.example` to `.env.production`
   - Tell user: "Fill in your production values in `.env.production`, then confirm."
   - Wait for user confirmation
   - Run `bash ${COOLIFY_TOOLS}/set-envs.sh <COOLIFY_APP_UUID> .env.production`
   - Go to Phase 4
4. **Neither exists**:
   - Ask user: "List your environment variables (KEY=VALUE, one per line), or type 'skip' to set them manually in Coolify dashboard."
   - If skip: go to Phase 4
   - Otherwise: write provided vars to `.env.production` (one KEY=VALUE per line)
   - Run `bash ${COOLIFY_TOOLS}/set-envs.sh <COOLIFY_APP_UUID> .env.production`

### Phase 3c: Set Resource Limits

1. Analyze the project to determine appropriate CPU and memory limits. Read the Dockerfile, package.json, and any app code needed to understand the workload type.
2. Use these baselines, then adjust based on what you learn:
   - Static site (nginx/caddy serving files): 0.5 CPU / 256M memory
   - Lightweight API (Node/Bun, low traffic): 1 CPU / 512M memory
   - Heavy API (high traffic, background jobs, LLM calls): 2 CPU / 1G memory
   - Worker/queue processor: 1 CPU / 512M–1G memory
3. Set limits via Coolify API:
   ```bash
   source deploy/.env.deploy
   curl -sf -H "Authorization: Bearer ${COOLIFY_API_TOKEN}" \
     -H "Content-Type: application/json" \
     -X PATCH "${COOLIFY_BASE_URL}/api/v1/applications/${COOLIFY_APP_UUID}" \
     -d '{"limits_cpus":"<cpu>","limits_memory":"<memory>"}'
   ```
4. Tell user what limits were set and why.

### Phase 4: DNS Setup (Optional)

1. Ask user if they want to create Cloudflare DNS record
2. If **no** (DNS skipped):
   - Ask user: "What is your app domain? (e.g. myapp.example.com)"
   - Run `bash ${SKILL_TOOLS}/set-config.sh DOMAIN <value>`
   - Go to Phase 4b (update Coolify domain)
3. Run `bash ${SKILL_TOOLS}/get-config.sh`, check CLOUDFLARE_API_TOKEN and CLOUDFLARE_ZONE_ID
4. If CLOUDFLARE_API_TOKEN empty: ask user to fill it in .env.deploy, then confirm
5. If CLOUDFLARE_ZONE_ID empty:
   - Ask user for their root domain (e.g. `example.com`)
   - Run `bash ${CLOUDFLARE_TOOLS}/find-zone-id.sh <domain>` → capture zone ID
   - Run `bash ${SKILL_TOOLS}/set-config.sh CLOUDFLARE_ZONE_ID <zone-id>`
6. Get SUBDOMAIN from config, default to REPO_NAME
7. Run `bash ${SKILL_TOOLS}/set-config.sh SUBDOMAIN <value>`
8. Ask user: CNAME or A record (for multi-record projects, loop steps 8–9 for each record)
9. Ask user: target (domain for CNAME, IP for A)
10. Run `bash ${CLOUDFLARE_TOOLS}/create-record.sh <type> <subdomain> <target>`
11. Run `bash ${CLOUDFLARE_TOOLS}/get-zone-name.sh` → capture zone name
12. Construct DOMAIN=`${SUBDOMAIN}.${ZONE_NAME}`
13. Run `bash ${SKILL_TOOLS}/set-config.sh DOMAIN <DOMAIN>`

### Phase 4b: Update Coolify Domain

1. Run `bash ${SKILL_TOOLS}/get-config.sh`, parse COOLIFY_APP_UUID and DOMAIN
2. Run `bash ${COOLIFY_TOOLS}/update-app-domain.sh <COOLIFY_APP_UUID> https://<DOMAIN>`

### Phase 5: First Deploy

1. Check: `git remote get-url origin`
2. If no remote:
   - Get GITHUB_ORG and REPO_NAME from `bash ${SKILL_TOOLS}/get-config.sh`
   - Run: `gh repo create ${GITHUB_ORG}/${REPO_NAME} --private --source . --push`
3. Run: `bash deploy/deploy.sh`

### Phase 6: Done

Tell user: "Setup complete. For future deploys: `bash deploy/deploy.sh`. For other ops (logs, env, status), use the coolify skill."

## Tools

Run from project root. **DO NOT copy tool scripts to project.** Only copy assets listed in Assets section.

| Tool | Args | Output |
|------|------|--------|
| `get-config.sh` | none | key=value lines (non-sensitive only) |
| `set-config.sh` | `<key> <value>` | status |

## Assets

Copy these files to project (paths relative to this SKILL.md):

| Source | Destination |
|--------|-------------|
| `assets/.env.deploy.example` | `deploy/.env.deploy.example` |
| `assets/deploy.sh` | `deploy/deploy.sh` |

## Config Variables

| Variable | Description |
|----------|-------------|
| GITHUB_ORG | GitHub org/username (must be lowercase) |
| REPO_NAME | Repository name (must be lowercase) |
| DOMAIN | Full app domain (e.g. myapp.example.com) |
| SUBDOMAIN | DNS subdomain |
| COOLIFY_BASE_URL | Coolify dashboard URL |
| COOLIFY_API_TOKEN | Coolify API token |
| COOLIFY_SERVER_UUID | Coolify server UUID |
| COOLIFY_DEST_UUID | Coolify destination UUID |
| COOLIFY_APP_UUID | Auto-generated by create-app.sh |
| COOLIFY_WEBHOOK_URL | Auto-generated by create-app.sh |
| CLOUDFLARE_API_TOKEN | Cloudflare API token |
| CLOUDFLARE_ZONE_ID | Cloudflare zone ID |

## Report

After completing the skill, provide output following this format:

```md
## Coolify Setup

**Project**: [repo name]
**Status**: ✅ Completed | ❌ Failed

**Result**:
- Coolify app: [app name] ([app uuid])
- Image: [ghcr.io/org/repo]
- Webhook: configured
- Env vars: [N vars set from .env.production] | skipped
- Resource limits: [cpu] CPU / [memory] memory — [reason]
- DNS: [subdomain] → [target] | skipped
- Domain: [domain] (set in Coolify)

**Next**: Run `bash deploy/deploy.sh` for future deploys. For other ops, use the coolify skill.
```
