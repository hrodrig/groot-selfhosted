# SSH hardening for groot-inbox relay user

## authorized_keys

Restrict bastion's key to SFTP only:

```
command="/usr/lib/openssh/sftp-server",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3... groot@bastion
```

Options:

| Option | Effect |
|--------|--------|
| `command="/usr/lib/openssh/sftp-server"` | Only SFTP, no shell |
| `no-port-forwarding` | Block SSH tunneling |
| `no-X11-forwarding` | Block X11 |
| `no-agent-forwarding` | Block agent forwarding |
| `no-pty` | No pseudo-terminal |

## sshd_config (optional — global)

```sshconfig
# Restrict groot-inbox to sftp-only (alternative to per-key command=)
Match User groot-inbox
    ForceCommand internal-sftp
    PasswordAuthentication no
    PermitTTY no
    X11Forwarding no
    AllowTcpForwarding no
    PermitTunnel no
```

## File permissions

```bash
chmod 700 /home/groot-inbox/.ssh
chmod 600 /home/groot-inbox/.ssh/authorized_keys
chown -R groot-inbox:groot-inbox /home/groot-inbox/.ssh
```

## Firewall (iptables/nftables example)

Limit SSH to bastion IP only:

```bash
# Allow SSH only from bastion
iptables -A INPUT -p tcp --dport 22 -s <bastion-ip> -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP
```

## Audit

Monitor SFTP access:

```bash
journalctl -u sshd | grep groot-inbox
```
