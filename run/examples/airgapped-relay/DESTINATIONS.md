# Microsoft destinations (rclone)

GROOT does **not** upload directly to OneDrive or SharePoint. After the archive lands on the relay (or on an online bastion), **rclone** pushes it to Microsoft 365.

Configure one remote on the host that runs rclone (`groot-inbox` on the relay, or the bastion user in the [online topology](README.md#4-online-bastion-no-relay)).

## Choose a destination

| Goal | rclone backend | Suggested remote name | Typical path |
|------|----------------|----------------------|--------------|
| OneDrive Personal | `onedrive` | `onedrive` | `onedrive:groot-archives/` |
| OneDrive for Business (my files / folder) | `onedrive` | `onedrive` | `onedrive:groot-archives/` (folder you created in “My files”) |
| SharePoint site document library | `onedrive` (SharePoint site) | `sharepoint` | `sharepoint:groot-archives/` or `sharepoint:Sites/…/groot-archives/` |

All three use the same rclone **onedrive** storage type (`Storage> 22` / `Microsoft OneDrive`). The interactive wizard asks whether you mean OneDrive or a SharePoint **site**.

## Headless relay (recommended)

Relays are almost always **headless** (no browser). Do **not** choose auto-config `y` on the VPS.

### On the VPS (`rclone config`)

```bash
sudo -u groot-inbox -i rclone config
# n) New remote
# name> onedrive          # or sharepoint
# Storage> 22             # Microsoft OneDrive
# client_id>              # Enter (blank) unless IT gave you an app registration
# client_secret>          # Enter (blank) unless IT gave you a secret
# Edit advanced config? n
# Use auto config? n      # headless — important
```

rclone prints something like: run `rclone authorize "onedrive"` on a machine with a browser, then paste the result.

### On a laptop with a browser (Mac/Linux/Windows)

```bash
# Install rclone if needed (macOS): brew install rclone
rclone authorize "onedrive"
```

Sign in with the M365 account that owns the destination folder/site. Copy the **entire** JSON/token block from the terminal and paste it at `result>` on the VPS. Finish the wizard (choose **OneDrive Business** for a work “My files” folder, or the SharePoint site option for a team site).

Then smoke:

```bash
sudo -u groot-inbox -i rclone lsd onedrive:
sudo -u groot-inbox -i rclone ls onedrive:groot-archives    # or your folder
# mkdir only if the folder does not exist yet:
sudo -u groot-inbox -i rclone mkdir onedrive:groot-archives
```

## Entra ID: “Approval needed”

Locked-down tenants often block the public **rclone** app until an admin consents.

What you will see in the browser during `rclone authorize`:

1. **Approval needed** — list of Graph scopes (read/write files, etc.).
2. Optional justification box → **Request approval**.
3. Confirmation email from Microsoft Security: request **submitted** (not yet approved). An admin must approve; you get another mail when it is done. Requests can expire (often ~30 days).

Until approval:

- Leave `rclone config` on the VPS with **Ctrl+C** (do not leave it waiting on `result>` overnight).
- You can still validate the **SFTP inbox** hop (`groot collect` → `~/inbox/`) without Microsoft.
- After the approval email: run `rclone authorize "onedrive"` again, paste into a fresh `rclone config` (or `rclone config reconnect`), then set `RCLONE_REMOTE`.

Longer-term alternative: IT registers an Entra app with the needed Graph permissions, grants **admin consent**, and you put that `client_id` / `client_secret` into `rclone config` instead of leaving them blank (avoids the public rclone multi-tenant prompt).

## OneDrive (personal or business “My files”)

After a successful remote exists:

```bash
sudo -u groot-inbox -i rclone lsd onedrive:
sudo -u groot-inbox -i rclone ls onedrive:groot-archives
```

Env for the systemd unit ([rclone-destination.env.example](rclone-destination.env.example)):

```bash
# Folder under OneDrive “My files” (create the folder first in the web UI if needed):
RCLONE_REMOTE=onedrive:groot-archives/
```

## SharePoint (site library)

Same headless flow; at the drive-type prompt choose **SharePoint site** and paste the site URL if asked (`https://contoso.sharepoint.com/sites/Incidents`).

```bash
sudo -u groot-inbox -i rclone lsd sharepoint:
sudo -u groot-inbox -i rclone mkdir sharepoint:groot-archives
```

Env:

```bash
RCLONE_REMOTE=sharepoint:groot-archives/
```

Path layout is tenant-specific. Prefer a dedicated library or folder (for example `IncidentArchives/groot/`) rather than the site root.

## Smoke test (after OAuth works)

Drop a dummy archive and confirm it appears in the cloud path:

```bash
# On the rclone host
touch /home/groot-inbox/inbox/groot-smoke-test.tar.gz
# With Path unit enabled, the oneshot should fire; or run manually:
sudo -u groot-inbox rclone move /home/groot-inbox/inbox/ "$RCLONE_REMOTE" \
  --include "*.tar.gz" --delete-empty-src-dirs -v

sudo -u groot-inbox -i rclone ls "$RCLONE_REMOTE"
```

Note: groot SFTP upload may embed `run_id` in the remote basename (for example `….tar.<run_id>.gz`) so concurrent collects do not overwrite each other. The Path unit’s `--include "*.tar.gz"` still matches.

## Re-auth

```bash
sudo -u groot-inbox -i rclone config reconnect onedrive:     # or sharepoint:
```

## Tenant / Entra notes (checklist)

- Expect **admin approval** for the public rclone app on many corporate tenants (see above).
- Prefer a dedicated M365 user or app registration owned by the ops team for production incident archives.
- Retention and DLP on the library/folder still apply — large or sensitive `.tar.gz` evidence may need an exception.
- SFTP to the relay does **not** require Entra; only the rclone → Microsoft hop does.

## Out of scope

- Native `upload.sharepoint` / Graph client inside the **groot** binary — not planned.
- Full Entra ID / Conditional Access runbooks — use your org’s identity docs.
