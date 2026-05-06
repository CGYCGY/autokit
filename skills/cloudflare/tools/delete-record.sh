#!/usr/bin/env bash
set -euo pipefail

if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID in deploy/.env.deploy}"

RECORD_ID="${1:?Usage: $0 <record-id>}"

API="https://api.cloudflare.com/client/v4"

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -X DELETE "${API}/zones/${ZONE_ID}/dns_records/${RECORD_ID}")

deleted_id=$(echo "$response" | jq -r '.result.id // empty')

if [ -z "$deleted_id" ]; then
  echo "Error: Failed to delete DNS record" >&2
  echo "$response" | jq -r '.errors // .' >&2
  exit 1
fi

echo "$deleted_id"
