# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-06-16

### Added

- **On-demand in-cluster Deployment** (`run/deploy/k8s/ondemand-deployment.yaml`): long-lived pod in namespace `groot` for `kubectl exec groot collect` (no CronJob). ConfigMap + PVC + RBAC included; `k8s/README.md` documents CronJob vs on-demand.

## [0.2.0] - 2026-06-16

### Added

- **Airgapped relay playbook**: `run/examples/airgapped-relay/` — bastion → SFTP → rclone → OneDrive topology with systemd watcher and SSH hardening.

### Changed

- Upstream pin bumped to **v0.7.0** (groot SFTP upload).

## [0.1.3] - 2026-06-15

### Changed

- **Helm repo URL reverted:** charts and **`index.yaml`** publish on **`https://hrodrig.github.io/groot-selfhosted`** again (operator repo **`gh-pages`**) — keeps the product repo free of deploy artifacts.
- **Release Charts workflow:** restored in-repo **chart-releaser** (pgwd-selfhosted pattern); removed cross-repo dispatch to **`hrodrig/groot`**.
- **Helm chart `version:`** → **0.1.3** (republish after revert).

## [0.1.2] - 2026-06-15

### Changed

- **Helm repo URL (reverted in 0.1.3):** attempted publish to **`https://hrodrig.github.io/groot`** via cross-repo workflow.
- **Release Charts workflow:** dispatched **`publish-helm-charts`** on **`hrodrig/groot`** (required **`GROOT_PAGES_TOKEN`**).
- **Helm chart `version:`** → **0.1.2**.

## [0.1.1] - 2026-06-15

### Added

- **Helm chart GitHub Pages repo:** [`.github/workflows/release-charts.yml`](.github/workflows/release-charts.yml) (chart-releaser + **`gh-pages`** **`index.yaml`**).
- **`run/deploy/helm/helm-repo-landing/`** — browser landing page + **`.nojekyll`** for Pages.
- **Install from Helm repo:** `helm repo add groot https://hrodrig.github.io/groot-selfhosted` (documented in README and deploy runbooks).

### Changed

- **Helm chart `version:`** → **0.1.1** (first packaged chart release for chart-releaser).

## [0.1.0] - 2026-06-15

### Added

- Initial **groot-selfhosted** repository: operator deployment docs and manifests split from [groot](https://github.com/hrodrig/groot) v0.6.1.
- **`run/deploy/`**: Helm chart and flat CronJob manifests (moved from upstream `deploy/`).
- **`run/docker/`**: `docker run` / Podman patterns with kubeconfig and output volume.
- **`run/standalone/`**: cron and systemd one-shot examples from Releases binary.
- **`run/examples/`**: minimal operator `groot.yml` with link to upstream full sample.
- **`CONTRIBUTING.md`**, **`CODE_OF_CONDUCT.md`**, **`SECURITY.md`** — community and reporting docs (pgwd/kzero pattern).
- **`.github/workflows/`** — CI (release metadata), Helm lint + kubeconform, GitHub Release on `v*` tags.
- **`testing/scripts/`** — `release-check.sh`, `extract-changelog.sh` (see [testing/README.md](testing/README.md)).

### Changed

- Helm chart default image pin: **`ghcr.io/hrodrig/groot:0.6.1`**.

[Unreleased]: https://github.com/hrodrig/groot-selfhosted/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/hrodrig/groot-selfhosted/releases/tag/v0.1.1
[0.1.0]: https://github.com/hrodrig/groot-selfhosted/releases/tag/v0.1.0
