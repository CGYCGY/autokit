#!/usr/bin/env bash
set -euo pipefail

if [ -f "deploy/.env.deploy" ]; then
  set -a && source "deploy/.env.deploy" && set +a
fi

CF_TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in deploy/.env.deploy}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:?Set CLOUDFLARE_ACCOUNT_ID in deploy/.env.deploy}"

TUNNEL_ID="${1:?Usage: $0 <tunnel-id> <routes-file>}"
ROUTES_FILE="${2:?Usage: $0 <tunnel-id> <routes-file>}"

if [ ! -f "$ROUTES_FILE" ]; then
  echo "Error: routes file not found: ${ROUTES_FILE}" >&2
  exit 1
fi

API="https://api.cloudflare.com/client/v4"

# Routes file is TSV. Order is preserved (Cloudflare matches top-to-bottom).
# Columns:
#   1. hostname           (required, e.g. mail.example.com or *.example.com)
#   2. service            (required, e.g. http://localhost:8080 or https://localhost:443)
#   3. originServerName   (optional, hostname expected on origin cert)
#   4. noTLSVerify        (optional, "true" disables origin cert verification)
# Lines starting with # and blank lines are ignored.
INGRESS=$(jq -n '[]')

while IFS=$'\t' read -r hostname service origin_sn no_tls_verify || [ -n "$hostname" ]; do
  # Skip blanks and comments
  [ -z "${hostname// }" ] && continue
  case "$hostname" in \#*) continue ;; esac

  if [ -z "${service// }" ]; then
    echo "Error: missing service for hostname '${hostname}'" >&2
    exit 1
  fi

  entry=$(jq -n \
    --arg hostname "$hostname" \
    --arg service "$service" \
    '{hostname: $hostname, service: $service}')

  origin_request=$(jq -n '{}')
  if [ -n "${origin_sn:-}" ] && [ -n "${origin_sn// }" ]; then
    origin_request=$(echo "$origin_request" | jq --arg v "$origin_sn" '. + {originServerName: $v}')
  fi
  if [ "${no_tls_verify:-}" = "true" ]; then
    origin_request=$(echo "$origin_request" | jq '. + {noTLSVerify: true}')
  fi
  if [ "$(echo "$origin_request" | jq 'length')" -gt 0 ]; then
    entry=$(echo "$entry" | jq --argjson or "$origin_request" '. + {originRequest: $or}')
  fi

  INGRESS=$(echo "$INGRESS" | jq --argjson e "$entry" '. + [$e]')
done < "$ROUTES_FILE"

if [ "$(echo "$INGRESS" | jq 'length')" -eq 0 ]; then
  echo "Error: no routes parsed from ${ROUTES_FILE}" >&2
  exit 1
fi

# Cloudflare requires the final ingress entry to be a catch-all with no
# hostname. Append http_status:404 unless the file already ended with one.
last_has_hostname=$(echo "$INGRESS" | jq '.[-1] | has("hostname")')
if [ "$last_has_hostname" = "true" ]; then
  INGRESS=$(echo "$INGRESS" | jq '. + [{service: "http_status:404"}]')
fi

BODY=$(jq -n --argjson ingress "$INGRESS" '{config: {ingress: $ingress}}')

response=$(curl -sf \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -X PUT "${API}/accounts/${ACCOUNT_ID}/cfd_tunnel/${TUNNEL_ID}/configurations" \
  -d "$BODY")

success=$(echo "$response" | jq -r '.success')
if [ "$success" != "true" ]; then
  echo "Error: Failed to set tunnel ingress" >&2
  echo "$response" | jq -r '.errors' >&2
  exit 1
fi

echo "ok"
