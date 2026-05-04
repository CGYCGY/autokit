#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

APP_UUID="${1:?Usage: $0 <app-uuid> [lines]}"
LINES="${2:-100}"

API="${COOLIFY_URL}/api/v1"

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  "${API}/applications/${APP_UUID}/logs?lines=${LINES}") || {
  echo "Error: failed to fetch logs for app ${APP_UUID}" >&2
  exit 1
}

# Response may be JSON {"logs": "..."} or plain text
if echo "$response" | jq -e 'type == "object" and has("logs")' > /dev/null 2>&1; then
  echo "$response" | jq -r '.logs'
elif echo "$response" | jq -e 'type == "string"' > /dev/null 2>&1; then
  echo "$response" | jq -r '.'
else
  # Check for error response
  if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
    msg=$(echo "$response" | jq -r '.message')
    if echo "$msg" | grep -qi "not found\|does not exist"; then
      echo "Error: application ${APP_UUID} not found" >&2
      exit 1
    fi
    # Log fetching not supported by this Coolify instance
    if echo "$msg" | grep -qi "not support\|unavailable"; then
      echo "Error: log fetching is not supported by this Coolify instance" >&2
      exit 2
    fi
    echo "Error: ${msg}" >&2
    exit 1
  fi
  echo "$response"
fi
