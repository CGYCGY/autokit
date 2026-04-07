#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ZONE_ID="${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID in deploy/.env.deploy}"

FILTER_TYPE="${1:-}"
FILTER_NAME="${2:-}"

API="https://api.cloudflare.com/client/v4"

page=1
while true; do
  query="${API}/zones/${ZONE_ID}/dns_records?per_page=100&page=${page}"
  [ -n "$FILTER_TYPE" ] && query="${query}&type=${FILTER_TYPE}"
  [ -n "$FILTER_NAME" ] && query="${query}&name=${FILTER_NAME}"

  response=$(curl -sf \
    -H "Authorization: Bearer ${CF_TOKEN}" \
    "$query")

  success=$(echo "$response" | jq -r '.success')
  if [ "$success" != "true" ]; then
    echo "Error: Failed to list DNS records" >&2
    echo "$response" | jq -r '.errors' >&2
    exit 1
  fi

  echo "$response" | jq -r '.result[] | [.id, .type, .name, .content, (.proxied | tostring)] | join("|")'

  total_pages=$(echo "$response" | jq -r '.result_info.total_pages')
  if [ "$page" -ge "$total_pages" ]; then
    break
  fi
  page=$((page + 1))
done
