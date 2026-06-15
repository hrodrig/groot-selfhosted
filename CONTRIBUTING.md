# Contributing to groot-selfhosted

Thanks for improving how operators run **GROOT**.

## Ground rules

- Follow the [Code of Conduct](CODE_OF_CONDUCT.md).
- For **security issues**, see [SECURITY.md](SECURITY.md) (product vs operator reporting).

This repository is the **operator** companion to **[groot](https://github.com/hrodrig/groot)** (CLI, SPEC, releases, container image). Changes here should be **deployment docs and manifests** — not product behavior.

## Scope

| Belongs here | Belongs upstream in **groot** |
|--------------|----------------------------------|
| Helm chart, flat CronJob YAML, RBAC templates | CLI flags, collector behavior, bugs in `collect` |
| `run/docker/`, `run/standalone/`, operator examples | `docs/SPECIFICATIONS.md`, config schema, Go code |
| Pin updates for `ghcr.io/hrodrig/groot` in chart/docs | Image build, GoReleaser, release artifacts |

**Rule of thumb:** if it needs a Go change or SPEC update, open the PR on **groot** first (or link the upstream issue/PR here).

## How to contribute

- **Bugs in manifests or runbooks:** Open an [issue](https://github.com/hrodrig/groot-selfhosted/issues) with repro steps (Helm values, cluster version, expected vs actual).
- **Product / CLI issues:** [groot issues](https://github.com/hrodrig/groot/issues).
- **Pull requests:** Target **`develop`**. `main` is release-only; day-to-day work merges into `develop` first (same git flow as **groot**).

Use focused branches, for example `docs/helm-pvc-note` or `fix/chart-rbac-typo`.

## Before you open a PR

1. **English** for all docs and comments.
2. **Links:** grep for stale paths (`deploy/` in the product repo, old image tags, broken anchors).
3. **Upstream pin:** if you bump the default GROOT image tag, update consistently:
   - `run/deploy/helm/groot/Chart.yaml` (`appVersion`)
   - README / `run/README.md` / `AGENTS.md` pin lines
   - **`CHANGELOG.md`** under `[Unreleased]`
4. **Helm chart:** keep `values.yaml` comments aligned with [groot SPEC §9](https://github.com/hrodrig/groot/blob/main/docs/SPECIFICATIONS.md#9-configuration-examples); full config keys stay in upstream `configs/groot.yml.sample`.

No Go tests run in this repo — validate manifests with `helm lint run/deploy/helm/groot`, `helm template`, or the **Helm chart** GitHub Actions workflow when you change templates.

## Releases (maintainers)

Selfhosted versions (**`VERSION`**, badge in README) are **independent** from **groot** tags.

1. Merge **`develop` → `main`** when docs/manifests are ready.
2. Update **`CHANGELOG.md`** (move `[Unreleased]` to a version section).
3. Bump **`VERSION`** and README version badge.
4. Tag **`vX.Y.Z`** on `main` (annotated tag).

Coordinate **image pin** with a published **groot** release when possible (e.g. chart `appVersion` matches `ghcr.io/hrodrig/groot` tag).

## Security

For vulnerabilities in the **GROOT binary or collector**, use **[groot SECURITY.md](https://github.com/hrodrig/groot/blob/main/SECURITY.md)** — do not disclose product security issues only in this repo.

For issues in **operator docs/manifests** (RBAC too broad, example secrets in git, etc.), see **[SECURITY.md](SECURITY.md)** in this repo (private advisory preferred).

## Questions

Open an issue if scope is unclear (product vs operator).

## Resources

- [groot CONTRIBUTING](https://github.com/hrodrig/groot/blob/main/CONTRIBUTING.md) — product repo workflow
- [Open Source Guide](https://opensource.guide/how-to-contribute/)
