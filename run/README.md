# run/ — operator deployment index

This tree holds **how to run GROOT**, not the CLI source. Product docs: [groot](https://github.com/hrodrig/groot).

**Image pin (default in chart):** `ghcr.io/hrodrig/groot:0.6.1`

| Directory | Purpose |
|-----------|---------|
| [docker/](docker/README.md) | Run the published image on a bastion with kubeconfig + output volume |
| [deploy/](deploy/README.md) | In-cluster **Helm chart** and flat **CronJob** manifests |
| [standalone/](standalone/README.md) | **cron** and **systemd** one-shot using the Releases binary |
| [examples/](examples/README.md) | Minimal operator `groot.yml`; full schema → upstream sample |

## Pick a path

| You have… | Start here |
|-----------|------------|
| kubeconfig on a laptop / bastion | [docker/README.md](docker/README.md) |
| Kubernetes + Helm 3 | [deploy/README.md](deploy/README.md) — **`helm repo add groot https://hrodrig.github.io/groot-selfhosted`** |
| Kubernetes, no Helm | [deploy/k8s/cronjob.yaml](deploy/k8s/cronjob.yaml) |
| Linux host + cron only | [standalone/README.md](standalone/README.md) |
| Need a starter config | [examples/groot-minimal.yml](examples/groot-minimal.yml) |

## Related upstream docs

- [SPECIFICATIONS.md](https://github.com/hrodrig/groot/blob/main/docs/SPECIFICATIONS.md) — behavior contract
- [configs/groot.yml.sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample) — all config keys
- [groot README — Install](https://github.com/hrodrig/groot/blob/main/README.md#install-or-update) — deb, rpm, Homebrew, `go install`
