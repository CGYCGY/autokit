#!/usr/bin/env bash
set -euo pipefail

if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"
SERVER="${COOLIFY_SERVER_UUID:?Set COOLIFY_SERVER_UUID in deploy/.env.deploy}"

PROJECT_UUID="${1:?Usage: $0 <project-uuid> <type> <name> [environment-name]}"
SERVICE_TYPE="${2:?Usage: $0 <project-uuid> <type> <name> [environment-name]}"
SERVICE_NAME="${3:?Usage: $0 <project-uuid> <type> <name> [environment-name]}"
ENV_NAME_ARG="${4:-}"

INSTANT_DEPLOY="${INSTANT_DEPLOY:-true}"

API="${COOLIFY_URL}/api/v1"

if [ -n "$ENV_NAME_ARG" ]; then
  ENV_NAME="$ENV_NAME_ARG"
else
  ENV_NAME=$(curl -sf \
    -H "Authorization: Bearer ${TOKEN}" \
    "${API}/projects/${PROJECT_UUID}/environments" \
    | jq -r '.[0].name')

  if [ -z "$ENV_NAME" ] || [ "$ENV_NAME" = "null" ]; then
    ENV_NAME="production"
  fi
fi

PAYLOAD=$(jq -n \
  --arg server "$SERVER" \
  --arg project "$PROJECT_UUID" \
  --arg env_name "$ENV_NAME" \
  --arg type "$SERVICE_TYPE" \
  --arg name "$SERVICE_NAME" \
  --argjson instant_deploy "${INSTANT_DEPLOY}" \
  '{
    server_uuid: $server,
    project_uuid: $project,
    environment_name: $env_name,
    type: $type,
    name: $name,
    instant_deploy: $instant_deploy
  }')

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/services" \
  -d "$PAYLOAD")

uuid=$(echo "$response" | jq -r '.uuid // .service_uuid // empty')

if [ -z "$uuid" ]; then
  echo "Error: Failed to create service" >&2
  echo "$response" >&2
  exit 1
fi

echo "$uuid"
