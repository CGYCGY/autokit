#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID in deploy/.env.deploy}"

RECORD_TYPE="${1:?Usage: $0 <type> <name> <content> [proxied]}"
RECORD_NAME="${2:?Usage: $0 <type> <name> <content> [proxied]}"
RECORD_CONTENT="${3:?Usage: $0 <type> <name> <content> [proxied]}"
PROXIED="${4:-true}"

# Validate type
if [ "$RECORD_TYPE" != "CNAME" ] && [ "$RECORD_TYPE" != "A" ]; then
  echo "Error: type must be CNAME or A" >&2
  exit 1
fi

API="https://api.cloudflare.com/client/v4"

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/zones/${ZONE_ID}/dns_records" \
  -d "{
    \"type\": \"${RECORD_TYPE}\",
    \"name\": \"${RECORD_NAME}\",
    \"content\": \"${RECORD_CONTENT}\",
    \"ttl\": 1,
    \"proxied\": ${PROXIED}
  }")

success=$(echo "$response" | jq -r '.success')

if [ "$success" = "true" ]; then
  record_id=$(echo "$response" | jq -r '.result.id')
  echo "$record_id"
else
  echo "Error: Failed to create DNS record" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi
