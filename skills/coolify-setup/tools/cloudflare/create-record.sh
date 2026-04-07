#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID in deploy/.env.deploy}"

RECORD_TYPE="${1:?Usage: $0 <type> <name> <content> [proxied|priority]}"
RECORD_NAME="${2:?Usage: $0 <type> <name> <content> [proxied|priority]}"
RECORD_CONTENT="${3:?Usage: $0 <type> <name> <content> [proxied|priority]}"

API="https://api.cloudflare.com/client/v4"

# Validate type
case "$RECORD_TYPE" in
  A|AAAA|CNAME|MX|TXT|SRV|CAA) ;;
  *) echo "Error: type must be A, AAAA, CNAME, MX, TXT, SRV, or CAA" >&2; exit 1 ;;
esac

# Build the JSON body for create/update using jq to handle escaping safely
build_body() {
  local base
  base=$(jq -n \
    --arg type "$RECORD_TYPE" \
    --arg name "$RECORD_NAME" \
    --arg content "$RECORD_CONTENT" \
    '{type: $type, name: $name, content: $content, ttl: 1}')

  case "$RECORD_TYPE" in
    A|AAAA|CNAME)
      local proxied="${4:-true}"
      echo "$base" | jq --argjson proxied "$proxied" '. + {proxied: $proxied}'
      ;;
    MX)
      local priority="${4:-10}"
      echo "$base" | jq --argjson pri "$priority" '. + {priority: $pri}'
      ;;
    SRV)
      # RECORD_CONTENT: "weight port target", 4th arg is priority (default 0)
      local srv_weight srv_port srv_target srv_priority
      srv_weight=$(echo "$RECORD_CONTENT" | awk '{print $1}')
      srv_port=$(echo "$RECORD_CONTENT" | awk '{print $2}')
      srv_target=$(echo "$RECORD_CONTENT" | awk '{print $3}')
      srv_priority="${4:-0}"
      echo "$base" | jq \
        --argjson pri "$srv_priority" \
        --argjson w "$srv_weight" \
        --argjson p "$srv_port" \
        --arg t "$srv_target" \
        '. + {data: {priority: $pri, weight: $w, port: $p, target: $t}}'
      ;;
    CAA)
      # RECORD_CONTENT: "flags tag value"
      local caa_flags caa_tag caa_value
      caa_flags=$(echo "$RECORD_CONTENT" | awk '{print $1}')
      caa_tag=$(echo "$RECORD_CONTENT" | awk '{print $2}')
      caa_value=$(echo "$RECORD_CONTENT" | awk '{print $3}')
      echo "$base" | jq \
        --argjson flags "$caa_flags" \
        --arg tag "$caa_tag" \
        --arg val "$caa_value" \
        '. + {data: {flags: $flags, tag: $tag, value: $val}}'
      ;;
    TXT)
      echo "$base"
      ;;
  esac
}

BODY=$(build_body "$@")

# Upsert: check for existing record
existing=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  "${API}/zones/${ZONE_ID}/dns_records?type=${RECORD_TYPE}&name=${RECORD_NAME}")

existing_success=$(echo "$existing" | jq -r '.success')
if [ "$existing_success" != "true" ]; then
  echo "Error: Failed to query existing DNS records" >&2
  echo "$existing" | jq -r '.errors' >&2
  exit 1
fi

existing_id=$(echo "$existing" | jq -r '.result[0].id // empty')

if [ -n "$existing_id" ]; then
  response=$(curl -sf \
    -H "Authorization: Bearer ${CF_TOKEN}" \
    -H "Content-Type: application/json" \
    -X PUT "${API}/zones/${ZONE_ID}/dns_records/${existing_id}" \
    -d "$BODY")
else
  response=$(curl -sf \
    -H "Authorization: Bearer ${CF_TOKEN}" \
    -H "Content-Type: application/json" \
    -X POST "${API}/zones/${ZONE_ID}/dns_records" \
    -d "$BODY")
fi

success=$(echo "$response" | jq -r '.success')

if [ "$success" = "true" ]; then
  echo "$response" | jq -r '.result.id'
else
  echo "Error: Failed to create/update DNS record" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi
