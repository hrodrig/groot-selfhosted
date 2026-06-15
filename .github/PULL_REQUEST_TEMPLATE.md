## What changed

-

## Why

-

## How to test

- [ ] `testing/scripts/release-check.sh` (from repo root)
- [ ] If **`run/deploy/helm/`** changed: `helm lint run/deploy/helm/groot` and `helm template test run/deploy/helm/groot --namespace groot`
- [ ] Manual verification on a cluster or bastion (if applicable)

## Checklist

- [ ] PR targets **`develop`** (not `main`, except release merges)
- [ ] English docs; links to **groot** upstream where config schema is involved
- [ ] No real secrets, kubeconfigs, or webhook URLs in committed examples
- [ ] If default **GROOT image pin** changed: `Chart.yaml` `appVersion`, README pin, `CHANGELOG.md` updated
- [ ] Product behavior changes belong in **[groot](https://github.com/hrodrig/groot)** — not mixed here without upstream link
