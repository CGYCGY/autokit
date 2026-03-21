#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID in deploy/.env.deploy}"

API="https://api.cloudflare.com/client/v4"

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  "${API}/zones/${ZONE_ID}")

success=$(echo "$response" | jq -r '.success')

if [ "$success" = "true" ]; then
  echo "$response" | jq -r '.result.name'
else
  echo "Error: Failed to get zone name" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi
