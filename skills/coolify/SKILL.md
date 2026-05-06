---
name: coolify
description: Operate an existing Coolify app — redeploy, tail logs, set env vars, check deployment status, manage apps and projects via Coolify API. Use for any Coolify operation that is NOT first-time setup (use coolify-setup for first-time).
allowed-tools: Bash, Read, Write, Edit, Glob
user-invocable: true
---

# Coolify

## Purpose

API operations against an existing Coolify app. For first-time setup of a new project, use the `coolify-setup` skill instead.

## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools

## Required Project State

`deploy/.env.deploy` in project root with at least:

- `COOLIFY_BASE_URL`
- `COOLIFY_API_TOKEN`
- `COOLIFY_APP_UUID` (for app-specific operations)

## Recipes

### Redeploy

Build, push to GHCR, trigger Coolify webhook:

```bash
bash deploy/deploy.sh
```

Requires `deploy/deploy.sh` (scaffolded by `coolify-setup`) and `COOLIFY_WEBHOOK_URL` in `deploy/.env.deploy`.

### Set resource limits

```bash
source deploy/.env.deploy
curl -sf -H "Authorization: Bearer ${COOLIFY_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -X PATCH "${COOLIFY_BASE_URL}/api/v1/applications/${COOLIFY_APP_UUID}" \
  -d '{"limits_cpus":"<cpu>","limits_memory":"<memory>"}'
```

Baselines: static site `0.5 CPU / 256M`; lightweight API `1 CPU / 512M`; heavy API `2 CPU / 1G`; worker `1 CPU / 512M–1G`.

### Create app in non-default environment

List environments first, then pass the name as 4th arg to `create-app.sh`:

```bash
source deploy/.env.deploy
curl -sf -H "Authorization: Bearer ${COOLIFY_API_TOKEN}" \
  "${COOLIFY_BASE_URL}/api/v1/projects/<project-uuid>/environments"
```

## Tools

Run from project root.

| Tool | Args | Output |
|------|------|--------|
| `list-servers.sh` | none | `uuid\|name\|ip` per line |
| `list-projects.sh` | none | `uuid\|name\|desc` per line |
| `create-project.sh` | `<name>` | uuid |
| `create-app.sh` | `<project-uuid> <app-name> <image> [environment-name]` | uuid (also writes `COOLIFY_APP_UUID` and `COOLIFY_WEBHOOK_URL` to `deploy/.env.deploy`). Optional env vars: `DOCKER_IMAGE_TAG` (default `latest`), `EXPOSED_PORT` (overrides Dockerfile EXPOSE; default `80`), `PORTS_MAPPINGS` (e.g. `"25:25,587:587"`), `PERSISTENT_STORAGES` (e.g. `"vol-name:/data,vol2:/mnt"`) |
| `create-service.sh` | `<project-uuid> <type> <name> [environment-name]` | service uuid; deploys a one-click service template (`type` is the catalog slug, e.g. `cloudflared`). Set `INSTANT_DEPLOY=false` to skip auto-deploy. After create, use `set-envs.sh` to populate template env vars (e.g. tunnel token). |
| `set-envs.sh` | `<app-uuid> <env-file>` | status (reads file, never exposes values) |
| `update-app-domain.sh` | `<app-uuid> <fqdn>` | status |
| `get-deployment-status.sh` | `<app-uuid>` | status string (`queued`, `in_progress`, `finished`, `failed`) or `none` if no deployments yet |
| `get-app-logs.sh` | `<app-uuid> [lines]` | raw log lines (default 100); exit 2 if log API unavailable |
