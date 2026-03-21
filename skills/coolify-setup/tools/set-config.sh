#!/usr/bin/env bash
set -euo pipefail

KEY="${1:?Usage: $0 <key> <value>}"
VALUE="${2:?Usage: $0 <key> <value>}"

ENV_FILE="deploy/.env.deploy"

if grep -q "^${KEY}=" "$ENV_FILE" 2>/dev/null; then
  sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" "$ENV_FILE"
else
  echo "${KEY}=${VALUE}" >> "$ENV_FILE"
fi

echo "Set ${KEY}"
