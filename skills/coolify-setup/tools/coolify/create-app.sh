#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

COOLIFY_URL="${COOLIFY_BASE_URL:?Set COOLIFY_BASE_URL in deploy/.env.deploy}"
TOKEN="${COOLIFY_API_TOKEN:?Set COOLIFY_API_TOKEN in deploy/.env.deploy}"
SERVER="${COOLIFY_SERVER_UUID:?Set COOLIFY_SERVER_UUID in deploy/.env.deploy}"
DEST="${COOLIFY_DEST_UUID:?Set COOLIFY_DEST_UUID in deploy/.env.deploy}"

PROJECT_UUID="${1:?Usage: $0 <project-uuid> <app-name> <docker-image>}"
APP_NAME="${2:?Usage: $0 <project-uuid> <app-name> <docker-image>}"
IMAGE="${3:?Usage: $0 <project-uuid> <app-name> <docker-image>}"

API="${COOLIFY_URL}/api/v1"

# Infer port from deploy/Dockerfile EXPOSE directive
if [ -f "deploy/Dockerfile" ]; then
  EXPOSED_PORT=$(grep -i '^EXPOSE' deploy/Dockerfile | tail -1 | awk '{print $2}' | tr -d '[:space:]')
fi
EXPOSED_PORT="${EXPOSED_PORT:-80}"

# Get environment name from project
ENV_NAME=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  "${API}/projects/${PROJECT_UUID}/environments" \
  | jq -r '.[0].name')

if [ -z "$ENV_NAME" ] || [ "$ENV_NAME" = "null" ]; then
  ENV_NAME="production"
fi

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/applications/dockerimage" \
  -d "{
    \"server_uuid\": \"${SERVER}\",
    \"project_uuid\": \"${PROJECT_UUID}\",
    \"environment_name\": \"${ENV_NAME}\",
    \"destination_uuid\": \"${DEST}\",
    \"name\": \"${APP_NAME}\",
    \"docker_registry_image_name\": \"${IMAGE}\",
    \"docker_registry_image_tag\": \"latest\",
    \"ports_exposes\": \"${EXPOSED_PORT}\",
    \"instant_deploy\": true
  }")

uuid=$(echo "$response" | jq -r '.uuid')

if [ -z "$uuid" ] || [ "$uuid" = "null" ]; then
  echo "Error: Failed to create application" >&2
  echo "$response" >&2
  exit 1
fi

# Construct webhook URL and update .env.deploy
WEBHOOK_URL="${COOLIFY_URL}/api/v1/deploy?uuid=${uuid}&force=false"
sed -i '/^COOLIFY_WEBHOOK_URL=/d' deploy/.env.deploy
echo "COOLIFY_WEBHOOK_URL=${WEBHOOK_URL}" >> deploy/.env.deploy
sed -i '/^COOLIFY_APP_UUID=/d' deploy/.env.deploy
echo "COOLIFY_APP_UUID=${uuid}" >> deploy/.env.deploy

echo "$uuid"
