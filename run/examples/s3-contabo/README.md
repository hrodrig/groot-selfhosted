# Contabo Object Storage — S3 upload

Operator path: **`groot collect` → Contabo Object Storage** (S3-compatible). No Nextcloud, no FileZilla for day-to-day use. Same bucket can back a future **gfs** (presigned / share UI).

GROOT speaks **S3 / GCS / SFTP**. This playbook uses **`upload.s3`** + custom `endpoint` (path-style enabled automatically).

```
┌──────────────┐   PutObject (S3 API)   ┌────────────────────────────┐
│ Bastion /    │ ─────────────────────→ │ Contabo Object Storage     │
│ laptop       │   <region>.contabo…    │ bucket: <your-bucket>      │
│ (groot)      │                        │ prefix: captures/          │
└──────────────┘                        └────────────────────────────┘
```

Need a VPS inbox + FileZilla instead? → [sftp-vps/](../sftp-vps/README.md).
Airgapped → rclone Microsoft? → [airgapped-relay/](../airgapped-relay/README.md).

Upstream sample: [examples/upload/s3.yml](https://github.com/hrodrig/groot/blob/main/examples/upload/s3.yml).

## Checklist (once)

### A. Contabo Object Storage

- [ ] Object Storage purchased (e.g. 250 GB, region **European Union**)
- [ ] Bucket created — pick a private name (do not publish real names in git/docs)
- [ ] Bucket URL looks like `https://<region>.contabostorage.com/<your-bucket>` (copy host + bucket from the Contabo console)
- [ ] Region shown as **EU** (or your purchased region)
- [ ] **Public access inactive** (recommended)

### B. S3 credentials

Panel path:

**Account → Security and access → Object Storage S3 credentials**

- [ ] Row matches **your** Object Storage instance name in the panel
- [ ] Copy **Access Key** + **Secret Key** for **that** storage row (not another Contabo product key)
- [ ] Verify keys are correct: no leading/trailing spaces, no newlines, no quotes inside the value when exporting
- [ ] Never commit keys to git or paste into YAML

### C. Bastion / laptop — env

```bash
export AWS_ACCESS_KEY_ID='...'          # trim paste — trailing space → SignatureDoesNotMatch
export AWS_SECRET_ACCESS_KEY='...'
export AWS_REGION='EU'
# optional overrides (if not in YAML):
# export GROOT_UPLOAD_S3_BUCKET=<your-bucket>
# export GROOT_UPLOAD_S3_ENDPOINT=https://<region>.contabostorage.com
# export GROOT_UPLOAD_S3_KEY_PREFIX=captures/
```

Quick check after paste (lengths only — do not print secrets):

```bash
# expect no space/newline at end; Secret often looks "too long" if you pasted a trailing space
python3 -c 'import os; a=os.environ["AWS_ACCESS_KEY_ID"]; s=os.environ["AWS_SECRET_ACCESS_KEY"]; print("access_len", len(a), "secret_len", len(s), "access_stripped_ok", a==a.strip(), "secret_stripped_ok", s==s.strip())'
```

- [ ] Env set in the shell / systemd unit / CronJob secret that runs `groot`
- [ ] `secret_stripped_ok` / `access_stripped_ok` are **True** (or re-export without spaces)

### D. groot config

- [ ] `groot` installed (pin ≥ **v1.1.1** recommended — trims AWS env whitespace; still verify paste)
- [ ] Copy [groot.yml](groot.yml) → `/etc/groot/groot.yml` (adjust namespaces / `output_dir`)
- [ ] Set `bucket`, `region`, `endpoint`, `key_prefix` from **your** Contabo console (not the placeholders)

### E. Smoke

```bash
groot collect --config /etc/groot/groot.yml
# collect only (no upload):
# groot collect --config /etc/groot/groot.yml --no-upload
```

- [ ] Collect succeeds
- [ ] Object appears under `captures/` in your Contabo bucket (console or `aws s3 ls` with same endpoint)

Optional AWS CLI check (path-style):

```bash
aws s3 ls s3://<your-bucket>/captures/ \
  --endpoint-url https://<region>.contabostorage.com \
  --region EU
```

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `NoCredentialProviders` / auth failed | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` in same process as groot |
| `SignatureDoesNotMatch` (403) | Wrong secret, **trailing/leading space** on paste, or keys from a different Object Storage row; re-copy from panel and re-check strip |
| `PermanentRedirect` / wrong endpoint | Use the host from your Contabo bucket URL (e.g. `https://<region>.contabostorage.com`) |
| `NoSuchBucket` | Bucket name exact; region matches panel; storage instance ready |
| Upload skipped | `upload.enabled` / `upload.s3.enabled`; not using `--no-upload` |
| Works local, fails in CronJob | Secrets not mounted into the Job pod; watch for whitespace in K8s Secret data |

## Related

- Product contract: [SPEC upload](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md) (`GROOT_UPLOAD_S3_*`, `--no-upload`)
- SFTP VPS inbox: [sftp-vps/](../sftp-vps/README.md)
- Future native Nextcloud/WebDAV: upstream ROADMAP **#97** (not required for Contabo S3)
