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
  --set image.tag=v1.1.1
```

If **`helm repo add`** fails, use **From this repository** below until the first chart release completes.

### Air-gapped / private registry

`--set image.tag` still pulls **`ghcr.io/hrodrig/groot`** unless you override **`image.repository`**. Put **`image.pullSecrets`** on the chart so the CronJob **and** the Job ServiceAccount can pull (groot-trigger Jobs reuse that SA):

```bash
helm upgrade --install groot groot/groot \
  --namespace groot --create-namespace \
  --set image.repository=registry.example.com/your-org/groot \
  --set image.tag=v1.1.1 \
  --set 'image.pullSecrets[0].name=YOUR_PULL_SECRET'
```

### Beside groot-trigger (HTTP on-demand)

This chart already creates the collect Job ServiceAccount and collector ClusterRole. After install, apply only **groot-trigger** [`deploy/k8s/always/`](https://github.com/hrodrig/groot-trigger/blob/develop/deploy/k8s/README.md) — **do not** apply `job-sa/` (Helm owns SA `groot` when the release name is `groot`). Set trigger env `GROOT_JOB_SA` to the Helm ServiceAccount name.

## From this repository (clone)

From a clone of **groot-selfhosted** (repo root):

```bash
helm upgrade --install groot ./run/deploy/helm/groot \
  --namespace groot --create-namespace \
  --set image.tag=v1.1.1
```

## Examples

### Custom schedule and smaller PVC

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set schedule="0 2 * * *" \
  --set persistence.size=20Gi \
  --set image.tag=v1.1.1
```

### Embed config from file

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set-file config.grootYml=./prod-groot.yml \
  --set image.tag=v1.1.1
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

### S3 upload credentials + verbose upload logs

```bash
kubectl -n groot create secret generic groot-s3 \
  --from-literal=AWS_ACCESS_KEY_ID='...' \
  --from-literal=AWS_SECRET_ACCESS_KEY='...' \
  --from-literal=AWS_REGION='EU'

helm upgrade --install groot ./run/deploy/helm/groot \
  -n groot --create-namespace \
  --set-file config.grootYml=./prod-groot.yml \
  --set image.tag=v1.1.1 \
  --set 'extraEnvFrom[0].secretRef.name=groot-s3' \
  --set 'extraArgs[0]=--verbose'
```

Put `upload.s3` (bucket, endpoint, region) in `prod-groot.yml`. Never put access keys in the ConfigMap.

**Upload log note:** groot prints `s3 uploaded …` via `logger.OK`, which is **verbose-gated**. Without `--verbose` (or `extraArgs: [--verbose]`), collect may still upload successfully while Job logs show only INFO lines.

## Concurrency

`concurrencyPolicy: Forbid` prevents overlapping **scheduled** CronJob runs. It does **not** block:

```bash
kubectl -n groot create job --from=cronjob/<release> groot-manual-$(date +%s)
```

Manual Jobs can run in parallel and hammer the API / fill the PVC. HTTP on-demand collect is **[groot-trigger](https://github.com/hrodrig/groot-trigger)** (409 single-flight there, not in this CronJob).

### Disable PVC (emptyDir — archives lost when pod exits)

```bash
helm upgrade --install groot groot/groot \
  -n groot --create-namespace \
  --set persistence.enabled=false \
  --set image.tag=v1.1.1
```

## Configuration reference

| Value | Default | Purpose |
|-------|---------|---------|
| `schedule` | `0 */6 * * *` | Cron expression |
| `image.repository` | `ghcr.io/hrodrig/groot` | Container image (override for air-gapped mirrors) |
| `image.tag` | Chart `appVersion` (`v1.1.1`) | GHCR tag (**`v`-prefixed**). Bare `1.1.1` is normalized to `v1.1.1`. |
| `image.pullSecrets` | `[]` | CronJob pod pull secrets; also copied onto the Job SA unless `serviceAccount.imagePullSecrets` is set |
| `serviceAccount.imagePullSecrets` | `[]` (→ `image.pullSecrets`) | SA pull secrets so groot-trigger Jobs inherit registry auth |
| `podAnnotations` | `{}` | Job pod annotations (e.g. `sidecar.istio.io/inject: "false"`) |
| `podSecurityContext` / `securityContext` | distroless `65532` | Restricted PSS; `readOnlyRootFilesystem` + `/tmp` emptyDir |
| `extraArgs` | `[]` | Extra args after `collect --config …` (e.g. `--verbose` for upload OK lines) |
| `extraEnvFrom` | `[]` | `envFrom` entries (e.g. Secret with `AWS_*` for `upload.s3`) |
| `config.grootYml` | embedded minimal config | Full `groot.yml` in ConfigMap |
| `persistence.enabled` | `true` | PVC for `/out` |
| `persistence.size` | `10Gi` | PVC size |
| `rbac.create` | `true` | ClusterRole + Binding |
| `resources` | 100m/256Mi requests | Pod resources |
| `concurrencyPolicy` | `Forbid` | Scheduled ticks only — see **Concurrency** above |

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
