#!/usr/bin/env bash
set -euo pipefail

if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:?Set CLOUDFLARE_ACCOUNT_ID in deploy/.env.deploy}"

TUNNEL_ID="${1:?Usage: $0 <tunnel-id>}"

API="https://api.cloudflare.com/client/v4"

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  "${API}/accounts/${ACCOUNT_ID}/cfd_tunnel/${TUNNEL_ID}/token")

success=$(echo "$response" | jq -r '.success')
if [ "$success" != "true" ]; then
  echo "Error: Failed to fetch tunnel token" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi

# .result is the token string itself (not an object).
echo "$response" | jq -r '.result'
