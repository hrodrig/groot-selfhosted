# Airgapped relay — bastion → SSH → rclone → Microsoft cloud

End-to-end operator playbook when the Kubernetes cluster has **no outbound internet** (or you still want a single egress hop). GROOT runs on a **bastion**, uploads `.tar.gz` archives via **SFTP** to a **relay**, and the relay syncs to **OneDrive or SharePoint** with **rclone**.

GROOT itself only speaks **S3 / GCS / SFTP**. Microsoft destinations are **rclone on the edge**, not a native `upload.sharepoint` provider. See [DESTINATIONS.md](DESTINATIONS.md).

```
┌──────────┐   SFTP (SSH)   ┌──────────┐   rclone    ┌─────────────────────┐
│ Bastion  │ ──────────────→ │  Relay   │ ──────────→ │ OneDrive / SharePoint │
│ (groot)  │   port 22       │  (ipA)   │   OAuth    │ (Microsoft 365)      │
└──────────┘                 └──────────┘            └─────────────────────┘
   kubeconfig                    ↑
   no internet              one allowed
                             egress IP
```

If the bastion **has** internet and you do not need the SSH hop, see [§4 Online bastion](#4-online-bastion-no-relay).

## Prerequisites

| Component | Requirement |
|-----------|-------------|
| **Bastion** | Linux (amd64/arm64), `groot` binary (≥ v1.0.3), kubeconfig to cluster API, SSH keypair, outbound SSH to relay allowed |
| **Relay (ipA)** | Linux with internet access, `rclone` installed, SSH server, dedicated user `groot-inbox` |
| **Microsoft cloud** | rclone remote on the relay — OneDrive and/or SharePoint ([DESTINATIONS.md](DESTINATIONS.md)) |

## 1. Relay setup (ipA — do once)

### 1.1 Create dedicated user

```bash
sudo useradd -m -s /bin/bash groot-inbox
sudo mkdir -p /home/groot-inbox/inbox
sudo chown groot-inbox:groot-inbox /home/groot-inbox/inbox
```

### 1.2 SSH hardening

Add bastion's public key to `/home/groot-inbox/.ssh/authorized_keys`:

```
command="/usr/lib/openssh/sftp-server",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3... groot@bastion
```

See [ssh/hardening.md](ssh/hardening.md) for full lock-down.

### 1.3 rclone remote (OneDrive or SharePoint)

Follow [DESTINATIONS.md](DESTINATIONS.md): **headless** `rclone config` on the relay (`Use auto config? n`), then `rclone authorize "onedrive"` on a laptop with a browser. Corporate tenants often need **Entra admin approval** for the rclone app before OAuth completes — the SFTP inbox still works while you wait.

Smoke after OAuth succeeds:

```bash
sudo -u groot-inbox -i rclone lsd onedrive:      # or sharepoint:
```

### 1.4 Destination env + systemd watcher

```bash
sudo mkdir -p /etc/groot
sudo cp rclone-destination.env.example /etc/groot/rclone-destination.env
# Edit RCLONE_REMOTE=onedrive:groot-archives/  or  sharepoint:groot-archives/
sudo cp systemd/groot-inbox.path /etc/systemd/system/
sudo cp systemd/groot-inbox-upload.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now groot-inbox.path
```

Whenever a `.tar.gz` lands in `~/inbox/`, the oneshot runs `rclone move` to `$RCLONE_REMOTE` and removes the local copy.

## 2. Bastion setup

### 2.1 Install groot (≥ v1.0.3)

```bash
# macOS
brew install hrodrig/groot/groot

# Linux (deb)
curl -sL https://github.com/hrodrig/groot/releases/download/v1.0.3/groot_v1.0.3_linux_amd64.deb -o /tmp/groot.deb
sudo dpkg -i /tmp/groot.deb
```

### 2.2 SSH keypair

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_groot -C "groot@bastion" -N ""
# Copy public key to relay authorized_keys (see §1.2)
ssh-copy-id -i ~/.ssh/id_ed25519_groot groot-inbox@ipA.example.com
```

### 2.3 known_hosts

```bash
ssh-keyscan -H ipA.example.com >> /etc/groot/known_hosts
```

### 2.4 groot config

Copy [groot-bastion.yml](groot-bastion.yml) to `/etc/groot/groot.yml` and set env vars:

```bash
export GROOT_UPLOAD_SFTP_IDENTITY_FILE=/home/groot/.ssh/id_ed25519_groot
export KUBECONFIG=/home/groot/.kube/config
```

### 2.5 Preflight

```bash
groot validate --config /etc/groot/groot.yml
```

Fix RBAC or disk issues before the first scheduled run. See [groot SPEC §12](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md).

### 2.6 Run

```bash
groot collect --config /etc/groot/groot.yml
```

Output: `.tar.gz` uploaded to `groot-inbox@ipA:~/inbox/groot-capture-*.tar.gz` → systemd watcher → `rclone move` to OneDrive or SharePoint.

## 3. Schedule (cron)

```bash
# Run every 6 hours
0 */6 * * * GROOT_UPLOAD_SFTP_IDENTITY_FILE=/home/groot/.ssh/id_ed25519_groot KUBECONFIG=/home/groot/.kube/config /usr/local/bin/groot collect --config /etc/groot/groot.yml --quiet
```

## 4. Online bastion (no relay)

When the host that runs `groot collect` **already** has internet and Microsoft OAuth is allowed there, skip SFTP:

1. Keep `upload.enabled: false` (or omit upload) so the archive stays under `output_dir`.
2. Install rclone on the bastion; create the same remote as in [DESTINATIONS.md](DESTINATIONS.md).
3. Point a Path/oneshot (or cron) at `output_dir` instead of `/home/groot-inbox/inbox/`:

```bash
rclone move /var/lib/groot/out/ sharepoint:groot-archives/ \
  --include "groot-capture-*.tar.gz" --delete-empty-src-dirs -v
```

Use a dedicated service account / M365 user; do not embed OAuth tokens in the groot YAML.

## Verification

```bash
# Preflight (once after config changes)
groot validate --config /etc/groot/groot.yml

# After collect, inspect archive locally (optional)
groot inspect /path/to/groot-capture-*.tar.gz

# After collect, check relay inbox
ssh groot-inbox@ipA ls -la ~/inbox/

# Check Microsoft path (from relay) — remote name from DESTINATIONS.md
sudo -u groot-inbox -i rclone ls onedrive:groot-archives/
# or: sudo -u groot-inbox -i rclone ls sharepoint:groot-archives/

# systemd watcher status (from relay)
systemctl status groot-inbox.path groot-inbox-upload.service
```

## Troubleshooting

| Symptom | Check |
|---------|-------|
| `host key verification failed` | `known_hosts_file` path correct? Run `ssh-keyscan -H <host> >> <file>` |
| `identity_file is required` | Set `GROOT_UPLOAD_SFTP_IDENTITY_FILE` env var |
| `sftp create: permission denied` | Relay `~/inbox/` owned by `groot-inbox`? |
| watcher not firing | `systemctl status groot-inbox.path` → loaded? `journalctl -u groot-inbox.path` |
| wrong cloud folder | `/etc/groot/rclone-destination.env` → `RCLONE_REMOTE` |
| rclone auth expired | `sudo -u groot-inbox -i rclone config reconnect <remote>:` |
