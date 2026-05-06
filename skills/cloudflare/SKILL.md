---
name: cloudflare
description: Manage Cloudflare DNS records and Zero Trust tunnels — create/update/list/delete DNS records, find zone IDs, create cloudflared tunnels, fetch tunnel tokens, set tunnel ingress routes. Use when user wants to configure DNS or tunnels on Cloudflare.
allowed-tools: Bash, Read
user-invocable: true
---

# Cloudflare

## Purpose

DNS record management and Zero Trust tunnel management on Cloudflare via API.

## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools

## Required Project State

`deploy/.env.deploy` in project root with:

- `CLOUDFLARE_API_TOKEN` — must include DNS edit on the zone *and* `Cloudflare Tunnel Write` on the account if using tunnel tools
- `CLOUDFLARE_ZONE_ID` (use `find-zone-id.sh` to discover from a domain) — required for DNS tools
- `CLOUDFLARE_ACCOUNT_ID` — required for tunnel tools (`create-tunnel.sh`, `get-tunnel-token.sh`, `set-tunnel-ingress.sh`)

## Tools

Run from project root.

### DNS

| Tool | Args | Output |
|------|------|--------|
| `find-zone-id.sh` | `<domain>` | zone-id |
| `get-zone-name.sh` | none | zone name (e.g. `example.com`) |
| `list-records.sh` | `[type] [name-filter]` | `id\|type\|name\|content\|proxied` per line; paginates automatically |
| `create-record.sh` | `<type> <name> <content> [proxied\|priority]` | record-id; supports A, AAAA, CNAME, MX, TXT, SRV, CAA; idempotent (upserts by type+name) |
| `delete-record.sh` | `<record-id>` | deleted record-id (use `list-records.sh` to look up the id first) |

### Zero Trust Tunnels

| Tool | Args | Output |
|------|------|--------|
| `create-tunnel.sh` | `<tunnel-name>` | tunnel-id; creates a remotely-managed tunnel (`config_src: cloudflare`) with a generated secret |
| `get-tunnel-token.sh` | `<tunnel-id>` | connector token (paste into cloudflared `TUNNEL_TOKEN` env var) |
| `set-tunnel-ingress.sh` | `<tunnel-id> <routes-file>` | `ok`; replaces all ingress rules. Routes file is TSV: `hostname\tservice\t[originServerName]\t[noTLSVerify]`. Order is preserved (Cloudflare matches top-to-bottom — wildcards must be last). A `http_status:404` catch-all is auto-appended. |

> **Note:** Tunnel routes configured via API do NOT auto-create DNS records (the dashboard does, the API does not). After `set-tunnel-ingress.sh`, call `create-record.sh CNAME <hostname> <tunnel-id>.cfargotunnel.com true` for each routed hostname.
