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

## Helm chart publish (GitHub Pages)

The install path **`helm repo add groot https://hrodrig.github.io/groot`** expects **`index.yaml`** and packaged **`.tgz`** files on the **`gh-pages`** branch of the **product** repo [**hrodrig/groot**](https://github.com/hrodrig/groot) — not on **`groot-selfhosted`**. Static **`index.html`** and **`.nojekyll`** are copied from **`run/deploy/helm/helm-repo-landing/`** on each publish (short URL like the product site).

- **Chart sources:** this repo (**`run/deploy/helm/groot/`**).
- **Publish target:** [**hrodrig/groot**](https://github.com/hrodrig/groot) **`gh-pages`** via [**.github/workflows/publish-helm-charts.yml**](https://github.com/hrodrig/groot/blob/main/.github/workflows/publish-helm-charts.yml).
- **Trigger:** [**.github/workflows/release-charts.yml**](.github/workflows/release-charts.yml) here runs on **push tag `v*`** and **`repository_dispatch`**es **`publish-helm-charts`** to **`hrodrig/groot`** with the tag ref. **`workflow_dispatch`** on either repo can re-run a publish.
- **One-time setup:**
  1. **`hrodrig/groot` → Settings → Pages → Source:** branch **`gh-pages`**, folder **`/` (root)**.
  2. **`groot-selfhosted` → Settings → Secrets → Actions:** **`GROOT_PAGES_TOKEN`** — PAT (classic **`repo`** or fine-grained **contents: write** on **`hrodrig/groot`**) so **`repository_dispatch`** can reach the product repo.
- **Pre-merge validation:** [**helm-lint.yml**](.github/workflows/helm-lint.yml).
- **Release checklist (chart publish):** When the **chart** changes, bump **`Chart.yaml` `version:`** (semver) and **`appVersion`** if the GROOT image pin changes. Merge to **`main`**, push **`git tag -a v…`** and **`git push origin v…`**. Confirm **Release Charts** (selfhosted) and **Publish Helm charts** (groot) are green; then **`helm repo update`** on a test machine. **Repo `VERSION`** and Git tag **`v*`** snapshot the **whole repository** — they need not equal **`Chart.yaml` `version:`** if this release did not touch the chart.
- **“No chart changes detected”:** Normal when chart-releaser sees no diff under **`run/deploy/helm/`**. To ship a new **`.tgz`**, edit the chart, bump **`Chart.yaml` `version:`**, merge, and tag again.
- **First publish (`invalid reference: origin/gh-pages`):** The groot workflow bootstraps an orphan **`gh-pages`** branch when missing.

## Security

For vulnerabilities in the **GROOT binary or collector**, use **[groot SECURITY.md](https://github.com/hrodrig/groot/blob/main/SECURITY.md)** — do not disclose product security issues only in this repo.

For issues in **operator docs/manifests** (RBAC too broad, example secrets in git, etc.), see **[SECURITY.md](SECURITY.md)** in this repo (private advisory preferred).

## Questions

Open an issue if scope is unclear (product vs operator).

## Resources

- [groot CONTRIBUTING](https://github.com/hrodrig/groot/blob/main/CONTRIBUTING.md) — product repo workflow
- [Open Source Guide](https://opensource.guide/how-to-contribute/)
