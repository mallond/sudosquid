````md
# Clawdbot / OpenClaw Marketplace Droplet (doctl + API token only)

This README documents the **manual** (hand-run) steps to:

- import an SSH key into DigitalOcean using **doctl + API token**
- create the **Marketplace** Moltbot/OpenClaw/Clawdbot droplet
- inject your SSH key via **cloud-init user-data** so SSH key login works reliably
- SSH in
- delete the droplet when done

> No in-droplet app setup is performed here.

---

## Prereqs

- `doctl` installed
- A DigitalOcean API token in your shell:
  ```bash
  export DIGITALOCEAN_ACCESS_TOKEN="dop_v1_XXXXXXXXXXXXXXXX"
````

* `ssh-keygen` available (usually already installed)

---

## 1) Find the Marketplace image ID

List Marketplace app images and filter:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute image list-application --format ID,Name --no-header \
  | grep -iE 'moltbot|openclaw|clawdbot'
```

Pick the first column (ID). Example:

* `IMAGE_ID="215191019"`

---

## 2) Create a local SSH keypair

If you don’t already have the key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/clawdbot_doctl_ed25519 -N ""
```

---

## 3) Import your public key into DigitalOcean

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute ssh-key import clawdbot-key --public-key-file ~/.ssh/clawdbot_doctl_ed25519.pub
```

Get the key ID:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute ssh-key list --format ID,Name,Fingerprint --no-header
```

Pick the ID for `clawdbot-key`. Example:

* `SSH_KEY_ID="53789388"`

---

## 4) Create cloud-init user-data to force SSH key access

Create `cloud-init-ssh.yaml`:

```bash
PUBKEY="$(cat ~/.ssh/clawdbot_doctl_ed25519.pub)"

cat > cloud-init-ssh.yaml <<EOF
#cloud-config
users:
  - name: root
    ssh_authorized_keys:
      - ${PUBKEY}

write_files:
  - path: /etc/ssh/sshd_config.d/99-clawdbot-ssh.conf
    permissions: "0644"
    content: |
      PubkeyAuthentication yes
      PermitRootLogin yes

runcmd:
  - mkdir -p /root/.ssh
  - chmod 700 /root/.ssh
  - 'grep -qxF "${PUBKEY}" /root/.ssh/authorized_keys || echo "${PUBKEY}" >> /root/.ssh/authorized_keys'
  - chmod 600 /root/.ssh/authorized_keys
  - (command -v systemctl >/dev/null 2>&1 && systemctl restart ssh || service ssh restart || true)
EOF
```

---

## 5) Create the droplet (plain)

Set variables (replace the example IDs):

```bash
DROPLET_NAME="clawdbot-plain-$(date +%Y%m%d-%H%M%S)"
REGION="sfo3"
SIZE="s-2vcpu-4gb"
IMAGE_ID="215191019"     # <-- replace
SSH_KEY_ID="53789388"    # <-- replace
```

Create:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute droplet create "$DROPLET_NAME" \
  --region "$REGION" \
  --size "$SIZE" \
  --image "$IMAGE_ID" \
  --ssh-keys "$SSH_KEY_ID" \
  --tag-names "clawdbot,openclaw" \
  --user-data-file cloud-init-ssh.yaml \
  --enable-monitoring \
  --enable-ipv6 \
  --wait \
  --format "ID,Name,PublicIPv4,Status" \
  --no-header
```

This prints the droplet ID + Public IPv4.

---

## 6) SSH in

```bash
ssh -i ~/.ssh/clawdbot_doctl_ed25519 root@<PublicIPv4>
```

---

## 7) Check status / list droplets

By tag:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute droplet list --tag-name clawdbot --format ID,Name,PublicIPv4,Status --no-header
```

---

## 8) Delete droplet(s)

Delete a specific droplet:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute droplet delete 548766533 --force
```

Delete everything tagged `clawdbot`:

```bash
doctl --access-token "$DIGITALOCEAN_ACCESS_TOKEN" \
  compute droplet delete --tag-name clawdbot --force
```

---

## Notes / Gotchas

* If your droplet still shows “root password” in the panel, the `cloud-init-ssh.yaml` injection should still make SSH key login work.
* If SSH fails, verify your IP and try:

  ```bash
  ssh -vvv -i ~/.ssh/clawdbot_doctl_ed25519 root@<PublicIPv4>
  ```

```

If you want, paste the `grep -iE 'moltbot|openclaw|clawdbot'` output you see — I’ll tell you which `IMAGE_ID` line is the right one to standardize on.
::contentReference[oaicite:0]{index=0}
```
