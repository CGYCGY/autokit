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

# Optional env var overrides (backward compatible)
TAG="${DOCKER_IMAGE_TAG:-latest}"
PORTS_MAPPINGS="${PORTS_MAPPINGS:-}"
PERSISTENT_STORAGES="${PERSISTENT_STORAGES:-}"
INSTANT_DEPLOY="${INSTANT_DEPLOY:-true}"

API="${COOLIFY_URL}/api/v1"

# Resolve exposed port: env var override > Dockerfile EXPOSE > default 80
if [ -z "${EXPOSED_PORT:-}" ] && [ -f "deploy/Dockerfile" ]; then
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

# Build create payload; include ports_mappings only if set
PAYLOAD=$(jq -n \
  --arg server "$SERVER" \
  --arg project "$PROJECT_UUID" \
  --arg env_name "$ENV_NAME" \
  --arg dest "$DEST" \
  --arg name "$APP_NAME" \
  --arg image "$IMAGE" \
  --arg tag "$TAG" \
  --arg ports_exposes "$EXPOSED_PORT" \
  --arg ports_mappings "$PORTS_MAPPINGS" \
  --argjson instant_deploy "${INSTANT_DEPLOY}" \
  '{
    server_uuid: $server,
    project_uuid: $project,
    environment_name: $env_name,
    destination_uuid: $dest,
    name: $name,
    docker_registry_image_name: $image,
    docker_registry_image_tag: $tag,
    ports_exposes: $ports_exposes,
    instant_deploy: $instant_deploy
  } + (if $ports_mappings != "" then {ports_mappings: $ports_mappings} else {} end)')

response=$(curl -sf \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${API}/applications/dockerimage" \
  -d "$PAYLOAD")

uuid=$(echo "$response" | jq -r '.uuid')

if [ -z "$uuid" ] || [ "$uuid" = "null" ]; then
  echo "Error: Failed to create application" >&2
  echo "$response" >&2
  exit 1
fi

# Attach persistent storages if requested (separate API call per volume)
# Format: "name:mount-path[,name2:mount-path2]"
if [ -n "$PERSISTENT_STORAGES" ]; then
  IFS=',' read -ra STORAGE_ENTRIES <<< "$PERSISTENT_STORAGES"
  for entry in "${STORAGE_ENTRIES[@]}"; do
    vol_name="${entry%%:*}"
    mount_path="${entry#*:}"
    if [ -z "$vol_name" ] || [ -z "$mount_path" ] || [ "$vol_name" = "$mount_path" ]; then
      echo "Warning: skipping malformed storage entry '${entry}' (expected name:mount-path)" >&2
      continue
    fi
    storage_payload=$(jq -n \
      --arg type "persistent" \
      --arg name "$vol_name" \
      --arg mount "$mount_path" \
      '{type: $type, name: $name, mount_path: $mount}')
    storage_resp=$(curl -sf \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -X POST "${API}/applications/${uuid}/storages" \
      -d "$storage_payload") || {
      echo "Warning: failed to attach storage '${vol_name}:${mount_path}' (app UUID: ${uuid})" >&2
      continue
    }
    if ! echo "$storage_resp" | jq -e '.uuid // .id // .name' > /dev/null 2>&1; then
      echo "Warning: unexpected response attaching storage '${vol_name}': ${storage_resp}" >&2
    fi
  done
fi

# Construct webhook URL and update .env.deploy
WEBHOOK_URL="${COOLIFY_URL}/api/v1/deploy?uuid=${uuid}&force=false"
sed -i '/^COOLIFY_WEBHOOK_URL=/d' deploy/.env.deploy
echo "COOLIFY_WEBHOOK_URL=${WEBHOOK_URL}" >> deploy/.env.deploy
sed -i '/^COOLIFY_APP_UUID=/d' deploy/.env.deploy
echo "COOLIFY_APP_UUID=${uuid}" >> deploy/.env.deploy

echo "$uuid"
