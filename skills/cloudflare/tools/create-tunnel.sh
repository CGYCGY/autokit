#!/usr/bin/env bash
set -euo pipefail

if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:?Set CLOUDFLARE_ACCOUNT_ID in deploy/.env.deploy}"

TUNNEL_NAME="${1:?Usage: $0 <tunnel-name>}"

API="https://api.cloudflare.com/client/v4"

# Generate a 32-byte random secret (base64) for the tunnel.
# Required for remotely-managed tunnels so a connector can authenticate.
TUNNEL_SECRET=$(head -c 32 /dev/urandom | base64 | tr -d '\n')

BODY=$(jq -n \
  --arg name "$TUNNEL_NAME" \
  --arg secret "$TUNNEL_SECRET" \
  '{name: $name, config_src: "cloudflare", tunnel_secret: $secret}')

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/accounts/${ACCOUNT_ID}/cfd_tunnel" \
  -d "$BODY")

success=$(echo "$response" | jq -r '.success')
if [ "$success" != "true" ]; then
  echo "Error: Failed to create tunnel" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi

echo "$response" | jq -r '.result.id'
