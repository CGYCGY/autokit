#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

APP_UUID="${1:?Usage: $0 <app-uuid>}"

API="${COOLIFY_URL}/api/v1"

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  "${API}/deployments/applications/${APP_UUID}?take=1")

count=$(echo "$response" | jq 'if type == "array" then length else 0 end')

if [ "$count" = "0" ]; then
  echo "none"
  exit 0
fi

status=$(echo "$response" | jq -r '.[0].status // empty')

if [ -z "$status" ]; then
  echo "Error: malformed deployment response" >&2
  echo "$response" >&2
  exit 1
fi

echo "$status"
