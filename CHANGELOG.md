# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.13] - 2026-08-25

### Changed

- Upstream pin bumped to **v1.1.3** (positional archive naming with cluster anchor). Helm chart **`version:`** **0.1.15**, **`appVersion`** **`v1.1.3`**.
- Runbooks and chart defaults: Docker, flat manifests, Helm examples, helm-repo landing, and airgapped relay install pin **v1.1.3**.

## [0.2.12] - 2026-08-18

### Added

- Helm: `image.pullSecrets` on the CronJob pod; `serviceAccount.imagePullSecrets` (defaults to `image.pullSecrets`) so **groot-trigger** Jobs using the same SA inherit registry pull (#chart 0.1.14)
- Helm: `podAnnotations`, `podSecurityContext`, `securityContext` (distroless UID/GID `65532`, `readOnlyRootFilesystem`, `/tmp` emptyDir; Istio annotation example)

### Changed

- Chart **`version:`** **0.1.14** (`appVersion` still **v1.1.1**)
- Docs: air-gapped `image.repository`; dual-install with [groot-trigger](https://github.com/hrodrig/groot-trigger) (`deploy/k8s/always/` only — skip `job-sa/`)

## [0.2.11] - 2026-08-12

### Changed

- **Image pin:** GHCR tags are **`vX.Y.Z`** (and `latest`) — not bare `X.Y.Z`. Chart **`appVersion`** → **`v1.1.1`**, chart **`version`** → **0.1.13**. Flat CronJob image → `ghcr.io/hrodrig/groot:v1.1.1`. Helm `groot.image` helper prefixes `v` if missing so old `--set image.tag=1.1.1` still pulls.
- Helm: **`extraEnvFrom`** (e.g. Secret `AWS_*` for `upload.s3`) and **`extraArgs`** (e.g. `--verbose` for upload OK lines).
- Docs: `concurrencyPolicy: Forbid` ≠ blocking `kubectl create job --from=…`; upload success log is verbose-gated.

## [0.2.10] - 2026-08-11

### Added

- **SFTP storage VPS** operator example: [`run/examples/sftp-vps/`](run/examples/sftp-vps/README.md) — `groot.yml` + OpenSSH/FileZilla checklist (inbox without Nextcloud or rclone).
- **Contabo Object Storage** operator example: [`run/examples/s3-contabo/`](run/examples/s3-contabo/README.md) — `upload.s3` + Contabo S3-compatible endpoint checklist (keys via `AWS_*` env; placeholders only; warn on trailing spaces / `SignatureDoesNotMatch`).

### Changed

- Upstream pin bumped to **v1.1.1** (kubeconfig `~` expansion, unique `sessionBase` short, S3 credential trim). Helm chart **`version:`** **0.1.12**, **`appVersion`** **1.1.1**.
- Runbooks: Docker, flat manifests, Helm examples, and airgapped relay install pin **v1.1.1**.

## [0.2.9] - 2026-08-04

### Changed

- Upstream pin bumped to **v1.0.6** (man(1)+nfpm+BSD packaging, CONTRIBUTING collector guide, expanded `examples/`). Helm chart **`version:`** **0.1.11**, **`appVersion`** **1.0.6**.
- Runbooks: Docker, flat manifests, Helm examples, and airgapped relay install pin **v1.0.6**.

## [0.2.8] - 2026-07-29

### Added

- **Airgapped relay:** SharePoint / OneDrive as rclone destinations ([`DESTINATIONS.md`](run/examples/airgapped-relay/DESTINATIONS.md)) — headless `rclone authorize`, Entra admin-consent notes, OneDrive Business folder paths; `rclone-destination.env.example`; systemd unit reads `RCLONE_REMOTE`. Online bastion (no SFTP hop) section in the playbook README.

### Changed

- Upstream pin bumped to **v1.0.4** (security: `grpc` v1.82.1, OpenTelemetry v1.44.0; `-v` Usage dump fix). Helm chart **`version:`** **0.1.10**, **`appVersion`** **1.0.4**.
- Runbooks: Docker, flat manifests, Helm examples, and airgapped relay install pin **v1.0.4**.
- **Airgapped relay** framing: Microsoft cloud via rclone on the edge (not native groot upload). Index links in `run/README.md` and `run/examples/README.md`.

## [0.2.7] - 2026-07-12

### Changed

- Upstream pin bumped to **v1.0.3** (post-audit hygiene: Docker default CMD `--help`, `groot notify test`, email/GCS test coverage, `x/crypto` v0.54.0). Helm chart **`version:`** **0.1.9**, **`appVersion`** **1.0.3**.
- Runbooks: Docker, flat manifests, Helm examples, and airgapped relay install pin **v1.0.3**.
- Docker runbook: document bare `docker run` prints `--help` (v1.0.3+); pass subcommand explicitly for collect.

## [0.2.6] - 2026-07-11

### Changed

- Upstream pin bumped to **v1.0.2** (distroless **Debian 13** runtime base). Helm chart **`version:`** **0.1.8**, **`appVersion`** **1.0.2**.
- Runbooks: Docker, flat manifests, Helm examples, and airgapped relay install pin **v1.0.2**.

## [0.2.5] - 2026-07-10

### Changed

- Upstream pin bumped to **v1.0.1** (Go **1.26.5** security patch: **CVE-2026-39822**, **CVE-2026-42505**). Helm chart **`version:`** **0.1.7**, **`appVersion`** **1.0.1**.
- Runbooks: preflight/archive examples reference **v1.0.x**; airgapped relay install pin **v1.0.1**.

## [0.2.4] - 2026-06-29

### Changed

- Upstream pin bumped to **v0.9.2** (operator wins: `groot validate`, `groot inspect`, shell completion, exit codes, `--summary`, `run_id` in manifest/notify/upload, kubectl plugin). Helm chart **`version:`** **0.1.6**, **`appVersion`** **0.9.2**.
- Runbooks: preflight with **`groot validate`**, archive check with **`groot inspect`**, notify `{{run_id}}` example; upstream config profiles linked from [groot `examples/profiles/`](https://github.com/hrodrig/groot/tree/main/examples/profiles).
- SPEC/ROADMAP links point to repo-root paths in [groot](https://github.com/hrodrig/groot) (`SPECIFICATIONS.md`, `ROADMAP.md`).

## [0.2.3] - 2026-06-17

### Changed

- Upstream pin bumped to **v0.8.0** (workload resource RCA extras). Helm chart **`version:`** **0.1.5**, **`appVersion`** **0.8.0**.

## [0.2.2] - 2026-06-17

### Changed

- Upstream pin bumped to **v0.7.2** (groot node logs on AKS, version output). Helm chart **`version:`** **0.1.4**, **`appVersion`** **0.7.2**.

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

[Unreleased]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.12...HEAD
[0.2.12]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.11...v0.2.12
[0.2.11]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.10...v0.2.11
[0.2.10]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.9...v0.2.10
[0.2.9]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.6...v0.2.7
[0.2.6]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/hrodrig/groot-selfhosted/compare/v0.2.2...v0.2.3
[0.1.1]: https://github.com/hrodrig/groot-selfhosted/releases/tag/v0.1.1
[0.1.0]: https://github.com/hrodrig/groot-selfhosted/releases/tag/v0.1.0
