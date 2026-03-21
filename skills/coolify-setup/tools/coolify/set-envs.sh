#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

APP_UUID="${1:?Usage: $0 <app-uuid> <env-file>}"
ENV_FILE="${2:?Usage: $0 <app-uuid> <env-file>}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found" >&2
  exit 1
fi

API="${COOLIFY_URL}/api/v1"

# Parse env file: skip comments and blank lines, require KEY=VALUE format
data="["
first=true
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and blank lines
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue
  # Must contain =
  [[ "$line" != *"="* ]] && continue

  key="${line%%=*}"
  value="${line#*=}"

  # Skip empty keys
  [[ -z "$key" ]] && continue

  # Escape value for JSON
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"

  if [ "$first" = true ]; then
    first=false
  else
    data+=","
  fi
  data+="{\"key\":\"${key}\",\"value\":\"${value}\",\"is_preview\":false,\"is_build_time\":false}"
done < "$ENV_FILE"
data+="]"

if [ "$data" = "[]" ]; then
  echo "No environment variables found in $ENV_FILE"
  exit 0
fi

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/applications/${APP_UUID}/envs/bulk" \
  -d "{\"data\":${data}}")

if echo "$response" | jq -e '.message' > /dev/null 2>&1; then
  echo "Env vars set: $(echo "$response" | jq -r '.message')"
elif echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
  count=$(echo "$response" | jq 'length')
  echo "Env vars set: ${count} variables"
else
  echo "Error: Failed to set env vars" >&2
  echo "$response" >&2
  exit 1
fi
