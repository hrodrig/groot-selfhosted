# Standalone — cron and systemd

Run **`groot collect`** from the **Releases binary** on a Linux host with network access to the Kubernetes API (bastion, admin VM, CI runner).

Install the binary from [GitHub Releases](https://github.com/hrodrig/groot/releases) (`.deb`, `.rpm`, or `.tar.gz`). Full install table: [groot README](https://github.com/hrodrig/groot#install-or-update).

Copy a config (minimal example: [../examples/groot-minimal.yml](../examples/groot-minimal.yml); full schema: [upstream sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample)).

## cron (every 6 hours)

```cron
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
0 */6 * * * groot collect --config /etc/groot/groot.yml >> /var/log/groot-collect.log 2>&1
```

After `.deb` install, place config at `/etc/groot/groot.yml` (from `groot.yml.sample`) and edit for your cluster.

## systemd timer (one-shot service + schedule)

**`/etc/systemd/system/groot-collect.service`**

```ini
[Unit]
Description=GROOT Kubernetes log collection
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/groot collect --config /etc/groot/groot.yml
User=groot
Group=groot
```

**`/etc/systemd/system/groot-collect.timer`**

```ini
[Unit]
Description=Run GROOT collect every 6 hours

[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now groot-collect.timer
```

Create a dedicated **`groot`** user with read-only kubeconfig if required by policy.

## In-cluster CronJob

For collection **inside** the cluster, prefer [../deploy/README.md](../deploy/README.md) (Helm or flat YAML) instead of bastion cron.

## Docker instead of binary

See [../docker/README.md](../docker/README.md).
