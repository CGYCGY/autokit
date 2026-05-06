---
name: cloudflare-tunnel-coolify
description: Set up a Cloudflare Tunnel for a Coolify VPS so web traffic stops hitting ports 80/443 directly. Creates the tunnel, deploys cloudflared as a Coolify service, builds ingress routes (Coolify wildcard + any non-Coolify services like mail admin), swaps DNS to CNAMEs, and prints a firewall lockdown checklist. Use when user wants to hide their VPS IP behind a Cloudflare Tunnel.
allowed-tools: Bash, Read, Write, Edit, Glob, AskUserQuestion
user-invocable: true
---

# Cloudflare Tunnel for Coolify

## Purpose

Automate the doc at `docs/cloudflare-tunnel-coolify-setup.md`. End state: web traffic flows Browser → Cloudflare Edge → cloudflared (in Coolify) → localhost:443 (Coolify proxy) or other local services. VPS ports 80/443 can be closed.

What this skill does NOT do:
- **Firewall lockdown** (Step 5 in the doc) — has no API, runs on the VPS via ufw/iptables. Skill prints a checklist; user runs it.
- **Browser smoke test** — the skill pauses and asks the user to confirm.
- **Mail server hardening** — out of scope.

## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools
SKILL_ASSETS: ${CLAUDE_SKILL_DIR}/assets
COOLIFY_TOOLS: ${CLAUDE_SKILL_DIR}/../coolify/tools
CLOUDFLARE_TOOLS: ${CLAUDE_SKILL_DIR}/../cloudflare/tools
COOLIFY_SETUP_TOOLS: ${CLAUDE_SKILL_DIR}/../coolify-setup/tools

## Workflow

### Phase 0: Precondition Check

1. Verify `deploy/.env.deploy` exists. If not, tell user: "Run `coolify-setup` first, or create `deploy/.env.deploy` with Coolify + Cloudflare credentials." STOP.
2. Source `deploy/.env.deploy` and verify these are set (ask user to fill any missing, then confirm):
   - `CLOUDFLARE_API_TOKEN` — must include both **Zone DNS Edit** for the zone *and* **Cloudflare Tunnel Write** at the account scope. The DNS-only token from `coolify-setup` is NOT sufficient.
   - `CLOUDFLARE_ACCOUNT_ID`
   - `CLOUDFLARE_ZONE_ID`
   - `COOLIFY_BASE_URL`, `COOLIFY_API_TOKEN`, `COOLIFY_SERVER_UUID`
3. If `CLOUDFLARE_TUNNEL_ID` is already set in `.env.deploy`, ask user: "Existing tunnel `<id>` found. Reuse it, or create a new one?" Branch in Phase 1 accordingly.

### Phase 1: Create or Reuse Tunnel

1. If reusing existing tunnel: capture `CLOUDFLARE_TUNNEL_ID`, skip to step 4.
2. Run `bash ${CLOUDFLARE_TOOLS}/get-zone-name.sh` → capture zone name (e.g. `example.com`).
3. Ask user for tunnel name (default: `coolify` or zone name without TLD).
4. Run `bash ${CLOUDFLARE_TOOLS}/create-tunnel.sh <name>` → capture tunnel UUID.
5. Append to `deploy/.env.deploy`: `CLOUDFLARE_TUNNEL_ID=<uuid>` (use `${COOLIFY_SETUP_TOOLS}/set-config.sh` if available, else inline `sed`/`echo`).
6. Run `bash ${CLOUDFLARE_TOOLS}/get-tunnel-token.sh <tunnel-id>` → capture token (do not echo to stdout in user-visible output).

### Phase 2: Deploy cloudflared in Coolify

1. If `CLOUDFLARE_TUNNEL_SERVICE_UUID` already set in `.env.deploy`: ask user "Reuse existing cloudflared service?" If yes, skip to Phase 3.
2. Run `bash ${COOLIFY_TOOLS}/list-projects.sh`. Ask user to select an existing project or create a new one (`bash ${COOLIFY_TOOLS}/create-project.sh <name>`).
3. Ask user for service name (default: `cloudflared`).
4. Run `bash ${COOLIFY_TOOLS}/create-service.sh <project-uuid> cloudflared <service-name>` → capture service UUID.
   - **If this fails with "type not found" or similar**: the catalog slug isn't `cloudflared` on this Coolify version. Tell user: "Coolify's cloudflared template slug couldn't be guessed. Deploy cloudflared manually once via the Coolify dashboard (Service → search `Cloudflared`), then run `curl -sf -H 'Authorization: Bearer ${COOLIFY_API_TOKEN}' '${COOLIFY_BASE_URL}/api/v1/services' | jq` and tell me the `type` field for the service you just created." Pause and re-run with the correct slug.
5. Save service UUID to `.env.deploy` as `CLOUDFLARE_TUNNEL_SERVICE_UUID`.
6. Write the tunnel token to a temp env file (`mktemp`):
   ```
   TUNNEL_TOKEN=<token>
   ```
7. Run `bash ${COOLIFY_TOOLS}/set-envs.sh <service-uuid> <temp-file>`. Delete temp file immediately (`rm`).
   - **If the deploy doesn't connect**: the env var name expected by the template may differ (some versions use `TOKEN` or `CLOUDFLARE_TUNNEL_TOKEN`). Inspect the service's compose template via Coolify dashboard or `GET /api/v1/services/<uuid>`, identify the right name, re-run `set-envs.sh` with corrected key. Note the correct name in this skill's troubleshooting if found.
8. Verify the cloudflared connector shows healthy in Cloudflare Zero Trust dashboard before proceeding (ask user to confirm).

### Phase 3: Build Ingress Routes File

1. If `deploy/tunnel-routes.tsv` already exists: ask user "Reuse existing routes file?" If yes, show contents and skip to Phase 4.
2. Get zone name (re-use Phase 1 step 2).
3. Initialize `deploy/tunnel-routes.tsv` from `${SKILL_ASSETS}/routes.tsv.example`, replacing `example.com` with actual zone name.
4. Use AskUserQuestion to ask: "Any non-Coolify services to route through the tunnel? (e.g. mail admin, monitoring UI running directly on the VPS in Docker/systemd)"
   - For each service:
     - hostname (e.g. `mail`)
     - host port (e.g. `18080`)
     - protocol (`http` or `https`)
     - if `https`: ask whether origin uses a self-signed cert (→ noTLSVerify=true) and what hostname is on the cert (originServerName, optional)
   - Insert each as a row **above** the wildcard line in `tunnel-routes.tsv`.
5. Ask user: "Route the apex (`<zone>` itself, no subdomain) through the tunnel? Most Coolify users say yes since the apex is currently the A record being replaced."
   - If yes: append a route line `<zone>\thttps://localhost:443\t<zone>` after the wildcard (apex needs its own entry; `*` does not match the apex itself).
6. Show the final file to user, ask to confirm or edit before applying.
7. Add `deploy/tunnel-routes.tsv` to `.gitignore` (it's per-deployment config).

### Phase 4: Apply Ingress Configuration

1. Run `bash ${CLOUDFLARE_TOOLS}/set-tunnel-ingress.sh <tunnel-id> deploy/tunnel-routes.tsv`. Expect `ok`.

### Phase 5: DNS Swap

> The Cloudflare API does NOT auto-create CNAMEs for tunnel routes (only the dashboard does). This phase provisions DNS explicitly.

For each hostname in `deploy/tunnel-routes.tsv` that is NOT a wildcard (skip lines where hostname starts with `*`):

1. Compute the DNS name. For apex (`<zone>`), use `@` or the zone name (Cloudflare accepts both).
2. **Delete blocking AAAA records:**
   ```
   bash ${CLOUDFLARE_TOOLS}/list-records.sh AAAA <hostname>
   ```
   For each `id` returned, run `bash ${CLOUDFLARE_TOOLS}/delete-record.sh <id>`.
3. **Delete existing A records** (we're switching to CNAME; type can't be changed in place):
   ```
   bash ${CLOUDFLARE_TOOLS}/list-records.sh A <hostname>
   ```
   For each `id`, run `bash ${CLOUDFLARE_TOOLS}/delete-record.sh <id>`.
4. **Create proxied CNAME to the tunnel:**
   ```
   bash ${CLOUDFLARE_TOOLS}/create-record.sh CNAME <hostname> <tunnel-id>.cfargotunnel.com true
   ```

After looping all routes, tell user:
> "Existing subdomain CNAMEs that point to the apex now resolve through the tunnel automatically — no action needed for those, but verify they're all **proxied (orange cloud)** in the Cloudflare DNS dashboard. Grey-cloud CNAMEs will fail."

### Phase 6: Smoke Test Gate

Print the test plan:
- Apex: `https://<zone>` (if routed)
- Each non-Coolify hostname from the routes file
- One sample Coolify-managed subdomain (ask user for an example)

Tell user: "Open each in incognito and confirm it loads over HTTPS without errors. Reply when done."

Use AskUserQuestion: "Did everything load correctly? (yes / no)"

If **no**: print the troubleshooting table from `docs/cloudflare-tunnel-coolify-setup.md` (502 → originServerName, 526 → cert mismatch, wrong app loads → route order). Do NOT proceed to Phase 7. Offer to inspect: tunnel status, cloudflared logs (`bash ${COOLIFY_TOOLS}/get-app-logs.sh <service-uuid>` — note: this targets apps, may need adjustment for services), or DNS records.

### Phase 7: Firewall Lockdown Checklist (Manual)

Print this for the user to execute on the VPS over Tailscale SSH:

```
# Drop public web ports — tunnel handles them now
sudo ufw deny 80/tcp
sudo ufw deny 443/tcp

# Verify Tailscale + mail ports still allowed
sudo ufw status verbose
```

Expected final state:

| Port | Action |
|---|---|
| 41641/udp (Tailscale) | allow |
| 22/tcp (SSH, Tailscale-only) | restricted |
| 25, 465, 587, 993/tcp (Mail) | allow |
| 4190/tcp (Sieve) | allow if used |
| 80, 443/tcp (Web) | **deny** |

Tell user: "Run these on the VPS only after you confirmed Phase 6 worked. If anything breaks after lockdown, re-allow 80/443 temporarily to isolate the cause."

### Phase 8: Done

Print the report (see Report section).

## Report

```md
## Cloudflare Tunnel for Coolify

**Status**: ✅ Completed | ❌ Failed at Phase [N]

**Result**:
- Tunnel: [name] ([tunnel-id])
- Coolify cloudflared service: [name] ([service-uuid])
- Routes: [N specific routes + wildcard + apex?]
- DNS: [N records swapped to CNAME → tunnel]
- Smoke test: passed | failed | skipped

**Manual next step**: run firewall lockdown commands on VPS (see Phase 7 checklist).

**Adding new apps later**:
- Coolify-managed: deploy app → set domain to `<sub>.<zone>` → add proxied CNAME `<sub>` → `<zone>`. Wildcard route handles it automatically.
- Non-Coolify: edit `deploy/tunnel-routes.tsv` (add row above the wildcard) → re-run `set-tunnel-ingress.sh` → add proxied CNAME.
```

## Tools

This skill has no own tools — it composes `cloudflare/` and `coolify/` tools listed in those skills' SKILL.md.

## Assets

| Source | Destination |
|--------|-------------|
| `assets/routes.tsv.example` | `deploy/tunnel-routes.tsv` (after substituting zone name) |

## Config Variables (added to `deploy/.env.deploy`)

| Variable | Description |
|----------|-------------|
| CLOUDFLARE_ACCOUNT_ID | Required — account scope for tunnel API |
| CLOUDFLARE_TUNNEL_ID | Set by Phase 1 |
| CLOUDFLARE_TUNNEL_SERVICE_UUID | Set by Phase 2 (Coolify cloudflared service) |
