#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

API="${COOLIFY_URL}/api/v1"

response=$(curl -sf -H "Authorization: Bearer ${TOKEN}" "${API}/servers")

echo "$response" | jq -r '.[] | "\(.uuid)\t\(.name)\t\(.ip // "N/A")"' | while IFS=$'\t' read -r uuid name ip; do
  echo "${uuid}|${name}|${ip}"
done
