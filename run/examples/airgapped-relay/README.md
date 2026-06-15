# Airgapped Relay — bastion → SSH → rclone → OneDrive

End-to-end operator playbook for environments where the Kubernetes cluster has **no outbound internet**. GROOT runs on a **bastion** (has kubeconfig to the API), uploads `.tar.gz` archives via SFTP to a **relay host** (one allowed SSH hop with internet access), and the relay syncs to **OneDrive** via **rclone**.

```
┌──────────┐   SFTP (SSH)   ┌──────────┐   rclone    ┌──────────┐
│ Bastion  │ ──────────────→ │  Relay   │ ──────────→ │ OneDrive │
│ (groot)  │   port 22       │  (ipA)   │   OAuth    │ (cloud)  │
└──────────┘                 └──────────┘            └──────────┘
   kubeconfig                    ↑
   no internet              one allowed
                             egress IP
```

## Prerequisites

| Component | Requirement |
|-----------|-------------|
| **Bastion** | Linux (amd64/arm64), `groot` binary (≥ v0.7.0), kubeconfig to cluster API, SSH keypair, outbound SSH to relay allowed |
| **Relay (ipA)** | Linux with internet access, `rclone` installed, SSH server, dedicated user `groot-inbox` |
| **OneDrive** | rclone remote configured on relay (`rclone config`) |

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

### 1.3 rclone OneDrive remote

```bash
# As groot-inbox user
sudo -u groot-inbox -i rclone config
# Follow interactive prompts → name remote "onedrive"
# Authorize OAuth in browser on ipA

# Test
sudo -u groot-inbox -i rclone lsd onedrive:
```

### 1.4 systemd watcher (auto-sync to OneDrive)

Copy units:

```bash
sudo cp systemd/groot-inbox.path /etc/systemd/system/
sudo cp systemd/groot-inbox-upload.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now groot-inbox.path
```

Whenever a `.tar.gz` lands in `~/inbox/`, the service fires `rclone move` to `onedrive:groot-archives/` and removes the local copy.

## 2. Bastion setup

### 2.1 Install groot (≥ v0.7.0)

```bash
# macOS
brew install hrodrig/groot/groot

# Linux (deb)
curl -sL https://github.com/hrodrig/groot/releases/download/v0.7.0/groot_v0.7.0_linux_amd64.deb -o /tmp/groot.deb
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

### 2.5 Run

```bash
groot collect --config /etc/groot/groot.yml
```

Output: `.tar.gz` uploaded to `groot-inbox@ipA:~/inbox/groot-capture-*.tar.gz` → systemd watcher fires → `rclone move` to OneDrive.

## 3. Schedule (cron)

```bash
# Run every 6 hours
0 */6 * * * GROOT_UPLOAD_SFTP_IDENTITY_FILE=/home/groot/.ssh/id_ed25519_groot KUBECONFIG=/home/groot/.kube/config /usr/local/bin/groot collect --config /etc/groot/groot.yml --quiet
```

## Verification

```bash
# After collect, check relay inbox
ssh groot-inbox@ipA ls -la ~/inbox/

# Check OneDrive (from relay)
sudo -u groot-inbox -i rclone ls onedrive:groot-archives/

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
| rclone auth expired | `sudo -u groot-inbox -i rclone config reconnect onedrive:` |
