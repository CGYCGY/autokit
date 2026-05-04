#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

APP_UUID="${1:?Usage: $0 <app-uuid> <fqdn>}"
FQDN="${2:?Usage: $0 <app-uuid> <fqdn>}"

API="${COOLIFY_URL}/api/v1"

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X PATCH "${API}/applications/${APP_UUID}" \
  -d "{\"domains\": \"${FQDN}\"}")

if echo "$response" | jq -e '.uuid' > /dev/null 2>&1; then
  echo "Domain set: ${FQDN}"
else
  echo "Error: Failed to update app domain" >&2
  echo "$response" >&2
  exit 1
fi
