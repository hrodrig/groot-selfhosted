# Testing

This operator repo has **no Go source**. CI validates release metadata and the Helm chart.

| Script | Purpose |
|--------|---------|
| [`scripts/release-check.sh`](scripts/release-check.sh) | `VERSION`, README badge, and CHANGELOG section alignment |
| [`scripts/extract-changelog.sh`](scripts/extract-changelog.sh) | Release notes body for GitHub Releases |

**Helm chart:** validated in GitHub Actions [`.github/workflows/helm-lint.yml`](../.github/workflows/helm-lint.yml) (`helm lint` + `kubeconform`).

From the repository root:

```bash
chmod +x testing/scripts/release-check.sh
testing/scripts/release-check.sh
```

Before tagging **`vX.Y.Z`**, set **`RELEASE_TAG`** to match:

```bash
RELEASE_TAG=v0.1.0 testing/scripts/release-check.sh
```
