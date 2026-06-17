# groot-selfhosted — run GROOT in your environment

[![Version](https://img.shields.io/badge/version-0.2.3-blue)](./VERSION)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![CI](https://github.com/hrodrig/groot-selfhosted/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/hrodrig/groot-selfhosted/actions/workflows/ci.yml)
[![GROOT product](https://img.shields.io/github/v/release/hrodrig/groot?display_name=tag&label=groot&logo=github)](https://github.com/hrodrig/groot/releases)

**Product:** [github.com/hrodrig/groot](https://github.com/hrodrig/groot) — CLI, SPEC, releases, and **`ghcr.io/hrodrig/groot`** image.  
**This repo:** how to **deploy and schedule** GROOT (bastion, container, in-cluster CronJob).

GROOT is a **read-only Kubernetes log collector**. This repository holds **operator** material only: Helm chart, flat manifests, Docker/Podman runbooks, and cron/systemd wrappers. For install channels (deb, rpm, Homebrew, `go install`), see the [groot README](https://github.com/hrodrig/groot/blob/main/README.md).

**Upstream pin:** `ghcr.io/hrodrig/groot:0.8.0` · [SPEC](https://github.com/hrodrig/groot/blob/main/docs/SPECIFICATIONS.md) · [sample config](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample)

## Where to run GROOT

| Mode | Path | When |
|------|------|------|
| **Docker / Podman** (bastion) | [run/docker/README.md](run/docker/README.md) | Laptop or jump host with kubeconfig |
| **Helm CronJob** (in-cluster) | [run/deploy/README.md](run/deploy/README.md) | Scheduled collection inside the cluster |
| **On-demand Deployment** | [run/deploy/k8s/ondemand-deployment.yaml](run/deploy/k8s/ondemand-deployment.yaml) | Pod in `groot` namespace; `kubectl exec` to collect |
| **Flat CronJob YAML** | [run/deploy/k8s/cronjob.yaml](run/deploy/k8s/cronjob.yaml) | Scheduled collection without Helm |
| **cron / systemd** (standalone binary) | [run/standalone/README.md](run/standalone/README.md) | Host scheduler + Releases binary |
| **Example configs** | [run/examples/](run/examples/) | Minimal operator YAML |

Start at **[run/README.md](run/README.md)** for the full index.

## Quick start (Helm)

**Naming:** this repository is **`groot-selfhosted`**. The chart lives under **`run/deploy/helm/groot/`** — chart name **`groot`** (see **`Chart.yaml`**). After the first chart release, **`index.yaml`** and **`groot-<chart-version>.tgz`** are on [GitHub Pages](https://hrodrig.github.io/groot-selfhosted/index.yaml) — see [CONTRIBUTING.md](CONTRIBUTING.md).

**Install from the Helm repo (recommended after first chart publish):**

```bash
helm repo add groot https://hrodrig.github.io/groot-selfhosted
helm repo update
helm search repo groot -l
helm upgrade --install groot groot/groot \
  --namespace groot --create-namespace \
  --set image.tag=0.8.0
```

Use **`--version`** from **`helm search`** once the index is live. If **`helm repo add`** fails, the chart may not be published yet — use the clone path below.

**Install from a clone (no Helm repo required):**

```bash
git clone https://github.com/hrodrig/groot-selfhosted.git
cd groot-selfhosted
helm upgrade --install groot ./run/deploy/helm/groot \
  --namespace groot --create-namespace \
  --set image.tag=0.8.0
```

See [run/deploy/README.md](run/deploy/README.md) for custom config, PVC, and RBAC notes.

## Contributing

- **[CONTRIBUTING.md](CONTRIBUTING.md)** — scope (operator vs product), PR flow, and release notes for this repo.
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** — community standards (Contributor Covenant).
- **[SECURITY.md](SECURITY.md)** — where to report product vs operator vulnerabilities.

## License

MIT — see [LICENSE](./LICENSE).
