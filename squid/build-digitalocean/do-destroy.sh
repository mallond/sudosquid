#!/usr/bin/env bash
set -euo pipefail

: "${DIGITALOCEAN_ACCESS_TOKEN:?export DIGITALOCEAN_ACCESS_TOKEN=...}"
command -v doctl >/dev/null 2>&1 || { echo "missing: doctl"; exit 1; }

if [[ $# -lt 1 ]]; then
  echo "usage:"
  echo "  $0 <droplet-id|droplet-name>"
  echo "  $0 --tag <tagname>"
  exit 1
fi

if [[ "${1}" == "--tag" ]]; then
  TAG="${2:-}"
  [[ -n "${TAG}" ]] || { echo "missing tag name"; exit 1; }

  # Delete everything tagged (README shows --tag-name clawdbot). :contentReference[oaicite:4]{index=4}
  doctl --access-token "${DIGITALOCEAN_ACCESS_TOKEN}" \
    compute droplet delete --tag-name "${TAG}" --force
  exit 0
fi

TARGET="${1}"

# If numeric, treat as droplet ID; else resolve by exact name.
if [[ "${TARGET}" =~ ^[0-9]+$ ]]; then
  DROPLET_ID="${TARGET}"
else
  DROPLET_ID="$(
    doctl --access-token "${DIGITALOCEAN_ACCESS_TOKEN}" \
      compute droplet list --format ID,Name --no-header \
      | awk -v name="${TARGET}" '$2==name {print $1; exit}'
  )"
fi

[[ -n "${DROPLET_ID:-}" ]] || { echo "droplet not found: ${TARGET}"; exit 1; }

# Delete specific droplet (README shows compute droplet delete <id> --force). :contentReference[oaicite:5]{index=5}
doctl --access-token "${DIGITALOCEAN_ACCESS_TOKEN}" \
  compute droplet delete "${DROPLET_ID}" --force
