# run/ — operator deployment index

This tree holds **how to run GROOT**, not the CLI source. Product docs: [groot](https://github.com/hrodrig/groot).

**Image pin (default in chart):** `ghcr.io/hrodrig/groot:v1.1.1`

| Directory | Purpose |
|-----------|---------|
| [docker/](docker/README.md) | Run the published image on a bastion with kubeconfig + output volume |
| [deploy/](deploy/README.md) | In-cluster **Helm chart** and flat manifests (on-demand Deployment or CronJob) |
| [standalone/](standalone/README.md) | **cron** and **systemd** one-shot using the Releases binary |
| [examples/](examples/README.md) | Minimal operator `groot.yml`; full schema → upstream sample |

## Pick a path

| You have… | Start here |
|-----------|------------|
| kubeconfig on a laptop / bastion | [docker/README.md](docker/README.md) |
| Kubernetes + Helm 3 | [deploy/README.md](deploy/README.md) — **`helm repo add groot https://hrodrig.github.io/groot-selfhosted`** |
| Kubernetes, HTTP **on demand** (Job) | **[groot-trigger](https://github.com/hrodrig/groot-trigger)** — apply `deploy/k8s/always/` only if this Helm chart already created the Job SA |
| Kubernetes, collect **on demand** (`kubectl exec`) | [deploy/k8s/ondemand-deployment.yaml](deploy/k8s/ondemand-deployment.yaml) |
| Kubernetes, **scheduled** collection, no Helm | [deploy/k8s/cronjob.yaml](deploy/k8s/cronjob.yaml) |
| Linux host + cron only | [standalone/README.md](standalone/README.md) |
| Need a starter config | [examples/groot-minimal.yml](examples/groot-minimal.yml) |
| Archives on a VPS + FileZilla | [examples/sftp-vps/](examples/sftp-vps/README.md) (`upload.sftp` inbox; no Nextcloud) |
| Archives to Contabo Object Storage | [examples/s3-contabo/](examples/s3-contabo/README.md) (`upload.s3` + S3-compatible endpoint) |
| Archives to OneDrive / SharePoint | [examples/airgapped-relay/](examples/airgapped-relay/README.md) (rclone on the edge; not native in groot) |

## Related upstream docs

- [SPECIFICATIONS.md](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md) — behavior contract
- [configs/groot.yml.sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample) — all config keys
- [groot `examples/profiles/`](https://github.com/hrodrig/groot/tree/main/examples/profiles) — incident, airgap, EKS, compliance starters
- [groot README — Install](https://github.com/hrodrig/groot/blob/main/README.md#install-or-update) — deb, rpm, Homebrew, `go install`
