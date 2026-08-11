# Storage VPS — SFTP inbox + FileZilla

Operator path when you want archives on a **cheap Linux VPS** and pull them with **FileZilla** (or any SFTP client). No Nextcloud, no Microsoft cloud, no rclone.

GROOT uploads only over **S3 / GCS / SFTP**. This playbook uses **`upload.sftp`**.

```
┌──────────────┐   SFTP (SSH key)   ┌─────────────────┐
│ Bastion /    │ ─────────────────→ │ Storage VPS     │
│ laptop       │   port 22          │ groot-inbox     │
│ (groot)      │                    │ ~/inbox/*.tar.gz│
└──────────────┘                    └────────┬────────┘
                                             │ SFTP (FileZilla)
                                             ▼
                                      ┌─────────────┐
                                      │ Your laptop │
                                      └─────────────┘
```

Need OneDrive / SharePoint after the hop? Use [airgapped-relay/](../airgapped-relay/README.md) instead.

Upstream schema: [configs/groot.yml.sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample) · product SFTP sample: [examples/upload/sftp.yml](https://github.com/hrodrig/groot/blob/main/examples/upload/sftp.yml).

## Checklist (VPS once)

Copy and tick as you go.

### A. VPS base

- [ ] Fresh Linux VPS (Ubuntu/Debian OK); note public IP / DNS
- [ ] OpenSSH server installed and listening on **22** (or your chosen port)
- [ ] Firewall: allow SSH from **bastion IP** (upload) and from **your laptop / VPN** (FileZilla)
- [ ] Optional: fail2ban or cloud security group restrict to those IPs only
- [ ] Disk sized for retention (archives can be large — plan prune/cron later)

### B. Inbox user

```bash
sudo useradd -m -s /bin/bash groot-inbox
sudo mkdir -p /home/groot-inbox/inbox
sudo chown groot-inbox:groot-inbox /home/groot-inbox/inbox
```

- [ ] User `groot-inbox` exists
- [ ] `~/inbox` owned by that user (writable for SFTP upload)

### C. Keys — machine (groot) vs human (FileZilla)

Generate on the **bastion** (or laptop that runs `groot collect`):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_groot -C "groot@bastion" -N ""
```

On the **VPS**, install the **public** key for uploads (SFTP-only — recommended):

```bash
sudo -u groot-inbox mkdir -p /home/groot-inbox/.ssh
sudo -u groot-inbox chmod 700 /home/groot-inbox/.ssh
# Append (edit key material):
# command="/usr/lib/openssh/sftp-server",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAA... groot@bastion
sudo -u groot-inbox tee -a /home/groot-inbox/.ssh/authorized_keys >/dev/null <<'EOF'
command="/usr/lib/openssh/sftp-server",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 PASTE_GROOT_PUBLIC_KEY groot@bastion
EOF
sudo -u groot-inbox chmod 600 /home/groot-inbox/.ssh/authorized_keys
```

For **FileZilla**, add a **second** public key (your laptop) **without** the `command=` restriction *or* keep `ForceCommand internal-sftp` globally (FileZilla still works — it only needs SFTP):

```bash
# Second line: human key (SFTP browse / download)
# ssh-ed25519 AAAA... you@laptop
```

- [ ] Bastion private key stays on bastion only (`GROOT_UPLOAD_SFTP_IDENTITY_FILE`)
- [ ] FileZilla uses a separate key (or password auth disabled; prefer keys)
- [ ] `PasswordAuthentication no` for this user (see [airgapped-relay ssh/hardening.md](../airgapped-relay/ssh/hardening.md))

Optional `sshd` match (SFTP-only for the inbox user):

```sshconfig
Match User groot-inbox
    ForceCommand internal-sftp
    PasswordAuthentication no
    PermitTTY no
    X11Forwarding no
    AllowTcpForwarding no
    PermitTunnel no
```

Then `sudo systemctl reload sshd` (or `ssh`).

### D. Smoke without groot

From bastion:

```bash
sftp -i ~/.ssh/id_ed25519_groot -P 22 groot-inbox@storage.example.com
# sftp> put /tmp/hello.txt inbox/
# sftp> ls inbox
# sftp> bye
```

- [ ] Interactive SFTP put into `inbox/` succeeds

### E. Bastion / laptop — groot

- [ ] `groot` installed ([releases](https://github.com/hrodrig/groot/releases); pin ≥ **v1.1.1**, ideally current)
- [ ] Kubeconfig can reach the cluster API
- [ ] Copy [groot.yml](groot.yml) → `/etc/groot/groot.yml` (or another path) and set `host` / `user` / `remote_dir`
- [ ] Pin host key:

```bash
sudo mkdir -p /etc/groot
ssh-keyscan -H storage.example.com | sudo tee -a /etc/groot/known_hosts
```

- [ ] Export secrets (never commit):

```bash
export GROOT_UPLOAD_SFTP_IDENTITY_FILE="$HOME/.ssh/id_ed25519_groot"
# Optional overrides if omitted from YAML:
# export GROOT_UPLOAD_SFTP_HOST=storage.example.com
# export GROOT_UPLOAD_SFTP_USER=groot-inbox
# export GROOT_UPLOAD_SFTP_REMOTE_DIR=inbox
# export GROOT_UPLOAD_SFTP_KNOWN_HOSTS=/etc/groot/known_hosts
```

- [ ] Dry run upload:

```bash
groot collect --config /etc/groot/groot.yml
# or skip network upload while testing collect only:
# groot collect --config /etc/groot/groot.yml --no-upload
```

- [ ] Confirm `.tar.gz` appears under `~/inbox/` on the VPS

### F. FileZilla

| Field | Value |
|-------|--------|
| Protocol | **SFTP — SSH File Transfer Protocol** |
| Host | `storage.example.com` (or IP) |
| Port | `22` (or your SSH port) |
| Logon | **Key file** (OpenSSH private key for the human identity) |
| User | `groot-inbox` |
| Remote path | `/home/groot-inbox/inbox` (or `inbox` if chrooted) |

- [ ] Connect and download an archive
- [ ] Do **not** put the groot machine private key into FileZilla on a shared PC

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `known_hosts` / host key error | `ssh-keyscan` into `known_hosts_file`; do not set `allow_insecure_host_key: true` in prod |
| `permission denied` on put | Ownership of `~/inbox`; key in `authorized_keys`; SFTP-only `command=` still allows put |
| FileZilla login fails | Wrong key; `PasswordAuthentication` off; firewall blocks laptop IP |
| Upload OK, FileZilla empty | Looking at wrong path; or rclone playbook already moved files (this playbook does not) |
| Collect exit non-zero but archive local | `upload.continue_on_error`; check SFTP logs / `sshd` |

## Related

- Product flags/env: [SPEC upload](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md) (`GROOT_UPLOAD_SFTP_*`, `--no-upload`)
- Airgapped + rclone → Microsoft: [airgapped-relay/](../airgapped-relay/README.md)
- Future native Nextcloud/WebDAV: upstream ROADMAP **#97** (not required for this path)
