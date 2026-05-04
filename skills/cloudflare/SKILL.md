---
name: cloudflare
description: Manage Cloudflare DNS records — create, update, list A/AAAA/CNAME/MX/TXT/SRV/CAA records, find zone IDs, get zone names. Use when user wants to configure DNS on Cloudflare.
allowed-tools: Bash, Read
user-invocable: true
---

# Cloudflare

## Purpose

DNS record management on Cloudflare via API.

## Variables

SKILL_TOOLS: ${CLAUDE_SKILL_DIR}/tools

## Required Project State

`deploy/.env.deploy` in project root with:

- `CLOUDFLARE_API_TOKEN` (DNS edit permission for the zone)
- `CLOUDFLARE_ZONE_ID` (use `find-zone-id.sh` to discover from a domain)

## Tools

Run from project root.

| Tool | Args | Output |
|------|------|--------|
| `find-zone-id.sh` | `<domain>` | zone-id |
| `get-zone-name.sh` | none | zone name (e.g. `example.com`) |
| `list-records.sh` | `[type] [name-filter]` | `id\|type\|name\|content\|proxied` per line; paginates automatically |
| `create-record.sh` | `<type> <name> <content> [proxied\|priority]` | record-id; supports A, AAAA, CNAME, MX, TXT, SRV, CAA; idempotent (upserts by type+name) |
