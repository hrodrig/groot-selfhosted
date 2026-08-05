# In-cluster GROOT (Helm)

Install a **CronJob** that runs `groot collect` on a schedule using **`ghcr.io/hrodrig/groot`**.

Maintained in [groot-selfhosted](https://github.com/hrodrig/groot-selfhosted). Product behavior: [groot SPEC](https://github.com/hrodrig/groot/blob/main/SPECIFICATIONS.md).

## Prerequisites

- Kubernetes 1.24+
- Helm 3
- Read-only **ClusterRole** (included) or namespace-scoped RBAC if you customize templates
- Optional: PersistentVolume for `/out` archives (enabled by default)

## Helm repo (GitHub Pages)

Once **`index.yaml`** is published (see [CONTRIBUTING.md](../../../../CONTRIBUTING.md)):

```bash
helm repo add groot https://hrodrig.github.io/groot-selfhosted
helm repo update
helm search repo groot -l
helm upgrade --install groot groot/groot \
  --namespace groot --create-namespace \
  --set image.tag=1.0.6
```

If **`helm repo add`** fails, use **From this repository** below until the first chart release completes.

## From this repository (clone)

From a clone of **groot-selfhosted** (repo root):

```bash
helm upgrade --install groot ./run/deploy/helm/groot \
  --namespace groot --create-namespace \
  --set image.tag=1.0.6
```

## Examples

### Custom schedule and smaller PVC

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set schedule="0 2 * * *" \
  --set persistence.size=20Gi \
  --set image.tag=1.0.6
```

### Embed config from file

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set-file config.grootYml=./prod-groot.yml \
  --set image.tag=1.0.6
```

Example **`prod-groot.yml`** snippet:

```yaml
output_dir: /out
collection:
  namespaces: [kube-system, production]
  redact_secrets: true
notify:
  on_failure:
    enabled: true
  generic:
    enabled: true
    webhook_url: "https://hooks.internal.example/groot"
    body_template: '{"text":"{{summary}}","run_id":"{{run_id}}","failed":{{failed}}}'
  email:
    enabled: true
    host: smtp.corp.example
    from: groot@corp.example
    to: "sre-oncall@corp.example"
```

Use Kubernetes Secrets for passwords (env in CronJob) rather than plain text in ConfigMap when possible.

### Disable PVC (emptyDir — archives lost when pod exits)

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set persistence.enabled=false \
  --set image.tag=1.0.6
```

## Configuration reference

| Value | Default | Purpose |
|-------|---------|---------|
| `schedule` | `0 */6 * * *` | Cron expression |
| `image.repository` | `ghcr.io/hrodrig/groot` | Container image |
| `image.tag` | Chart `appVersion` | Image tag (set to release semver, e.g. `1.0.6`) |
| `config.grootYml` | embedded minimal config | Full `groot.yml` in ConfigMap |
| `persistence.enabled` | `true` | PVC for `/out` |
| `persistence.size` | `10Gi` | PVC size |
| `rbac.create` | `true` | ClusterRole + Binding |
| `resources` | 100m/256Mi requests | Pod resources |

## Uninstall

```bash
helm uninstall groot -n groot
# PVC is not removed by default — delete manually if needed:
# kubectl delete pvc -n groot -l app.kubernetes.io/instance=groot
```

## Security

Collected archives may contain secrets. Enable `collection.redact_secrets` in config. Restrict PVC access. See [groot Security note](https://github.com/hrodrig/groot#security-note).

## Flat manifests (no Helm)

See [`k8s/cronjob.yaml`](../../k8s/cronjob.yaml) and [`../README.md`](../README.md).
