#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"

PROJECT_NAME="${1:?Usage: $0 <project-name>}"

API="${COOLIFY_URL}/api/v1"

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/projects" \
  -d "{\"name\": \"${PROJECT_NAME}\", \"description\": \"Created by coolify-setup\"}")

uuid=$(echo "$response" | jq -r '.uuid')

if [ -z "$uuid" ] || [ "$uuid" = "null" ]; then
  echo "Error: Failed to create project" >&2
  echo "$response" >&2
  exit 1
fi

echo "$uuid"
