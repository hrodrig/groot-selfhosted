# AGENTS.md — groot-selfhosted

This repository documents **how to run GROOT** in operator environments. It is **not** the product repo.

| Repo | Role |
|------|------|
| **[groot](https://github.com/hrodrig/groot)** | CLI, behavior contract (SPEC), releases, container image build |
| **groot-selfhosted** (this repo) | Bastion, Docker/Podman, cron/systemd, Helm CronJob, flat Kubernetes manifests |

## Upstream pin

- **GROOT product:** [github.com/hrodrig/groot](https://github.com/hrodrig/groot) — pin **`v1.0.4`** for docs and chart defaults.
- **Image:** `ghcr.io/hrodrig/groot:1.0.4` (or `:v1.0.4` tag from Releases).
- **Full config schema:** [configs/groot.yml.sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample) and [SPECIFICATIONS.md](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md).

## Scope

- **`run/`** — operator paths: `docker/`, `deploy/`, `standalone/`, `examples/`.
- Do **not** add Go source, CLI flags, or product SPEC changes here — propose those upstream in **groot**.

## Language

English only for all artifacts in this repository.
