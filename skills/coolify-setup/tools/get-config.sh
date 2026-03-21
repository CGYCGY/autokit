#!/usr/bin/env bash
set -euo pipefail

# Load environment
if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

# Output only non-sensitive values
echo "GITHUB_ORG=${GITHUB_ORG:-}"
echo "REPO_NAME=${REPO_NAME:-}"
echo "SUBDOMAIN=${SUBDOMAIN:-}"
echo "DOMAIN=${DOMAIN:-}"
echo "COOLIFY_BASE_URL=${COOLIFY_BASE_URL:-}"
echo "COOLIFY_SERVER_UUID=${COOLIFY_SERVER_UUID:-}"
echo "COOLIFY_DEST_UUID=${COOLIFY_DEST_UUID:-}"
echo "COOLIFY_APP_UUID=${COOLIFY_APP_UUID:-}"
echo "COOLIFY_WEBHOOK_URL=${COOLIFY_WEBHOOK_URL:-}"
echo "CLOUDFLARE_ZONE_ID=${CLOUDFLARE_ZONE_ID:-}"
