#!/usr/bin/env bash
set -euo pipefail

# ---- tweakables (or override via env) ----
: "${DIGITALOCEAN_ACCESS_TOKEN:?export DIGITALOCEAN_ACCESS_TOKEN=...}"
: "${DROPLET_NAME:=clawdbot-plain-$(date +%Y%m%d-%H%M%S)}"
: "${REGION:=sfo3}"
: "${SIZE:=s-2vcpu-4gb}"
: "${IMAGE_ID:?set IMAGE_ID (Marketplace app image id)}"
: "${SSH_KEY_ID:?set SSH_KEY_ID (DO ssh key id)}"
: "${TAG_NAMES:=clawdbot,openclaw}"

: "${SSH_KEY_PATH:=$HOME/.ssh/clawdbot_doctl_ed25519}"
: "${CLOUD_INIT_FILE:=cloud-init-ssh.yaml}"

command -v doctl >/dev/null 2>&1 || { echo "missing: doctl"; exit 1; }
command -v ssh-keygen >/dev/null 2>&1 || { echo "missing: ssh-keygen"; exit 1; }

# Ensure local keypair exists (README uses ed25519 at ~/.ssh/clawdbot_doctl_ed25519). :contentReference[oaicite:1]{index=1}
if [[ ! -f "${SSH_KEY_PATH}" || ! -f "${SSH_KEY_PATH}.pub" ]]; then
  ssh-keygen -t ed25519 -f "${SSH_KEY_PATH}" -N ""
fi

PUBKEY="$(cat "${SSH_KEY_PATH}.pub")"

# Minimal cloud-init: force root authorized_keys + restart ssh. :contentReference[oaicite:2]{index=2}
cat > "${CLOUD_INIT_FILE}" <<EOF
#cloud-config
write_files:
  - path: /root/.ssh/authorized_keys
    owner: root:root
    permissions: '0600'
    content: |
      ${PUBKEY}
runcmd:
  - chmod 700 /root/.ssh
  - chmod 600 /root/.ssh/authorized_keys
  - (command -v systemctl >/dev/null 2>&1 && systemctl restart ssh || service ssh restart || true)
EOF

# Create droplet (Marketplace image id, ssh key id, tags, user-data-file, monitoring, ipv6, wait). :contentReference[oaicite:3]{index=3}
doctl --access-token "${DIGITALOCEAN_ACCESS_TOKEN}" \
  compute droplet create "${DROPLET_NAME}" \
  --region "${REGION}" \
  --size "${SIZE}" \
  --image "${IMAGE_ID}" \
  --ssh-keys "${SSH_KEY_ID}" \
  --tag-names "${TAG_NAMES}" \
  --user-data-file "${CLOUD_INIT_FILE}" \
  --enable-monitoring \
  --enable-ipv6 \
  --wait \
  --format "ID,Name,PublicIPv4,Status" \
  --no-header
