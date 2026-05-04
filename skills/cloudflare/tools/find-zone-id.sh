#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"

DOMAIN="${1:?Usage: $0 <domain>}"

API="https://api.cloudflare.com/client/v4"

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  "${API}/zones?name=${DOMAIN}")

success=$(echo "$response" | jq -r '.success')
if [ "$success" != "true" ]; then
  echo "Error: Failed to query zones" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi

count=$(echo "$response" | jq '.result | length')

if [ "$count" -eq 0 ]; then
  echo "Error: No zone found for domain '${DOMAIN}'" >&2
  exit 1
elif [ "$count" -gt 1 ]; then
  echo "Error: Multiple zones found for domain '${DOMAIN}':" >&2
  echo "$response" | jq -r '.result[] | .id + " " + .name' >&2
  exit 1
fi

echo "$response" | jq -r '.result[0].id'
