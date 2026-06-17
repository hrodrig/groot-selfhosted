# Deploy GROOT in-cluster

Scheduled **`groot collect`** inside Kubernetes using the published image **`ghcr.io/hrodrig/groot`**.

## Choose an approach

| Method | Path | Best for |
|--------|------|----------|
| **Helm repo** (GitHub Pages) | `helm repo add groot https://hrodrig.github.io/groot-selfhosted` | Production installs without cloning |
| **Helm (clone)** | [`helm/groot/`](helm/groot/) | GitOps fork, air-gapped copy |
| **On-demand Deployment** | [`k8s/ondemand-deployment.yaml`](k8s/ondemand-deployment.yaml) | Config in-cluster; `kubectl exec` to collect when you want |
| **Flat CronJob YAML** | [`k8s/cronjob.yaml`](k8s/cronjob.yaml) | Scheduled collection without Helm |

**Helm repo:** once [**Release Charts**](https://github.com/hrodrig/groot-selfhosted/blob/main/.github/workflows/release-charts.yml) has published **`index.yaml`**, install with **`groot/groot`** (repo/chart). Until then, use **From this repository** below.

## Helm quick start (GitHub Pages)

```bash
helm repo add groot https://hrodrig.github.io/groot-selfhosted
helm repo update
helm upgrade --install groot groot/groot \
  --namespace groot --create-namespace \
  --set image.tag=0.8.0
```

Pin chart semver when needed: **`helm search repo groot -l`** then **`--version <chart-version>`**.

Embed your config:

```bash
helm upgrade --install groot groot/groot \
  --namespace groot --create-namespace \
  --set-file config.grootYml=./groot.yml \
  --set image.tag=0.8.0 \
  --set schedule="0 2 * * *"
```

## From this repository (clone)

```bash
# Default: CronJob every 6h, PVC for /out, read-only ClusterRole
helm upgrade --install groot ./run/deploy/helm/groot \
  --namespace groot --create-namespace \
  --set image.tag=0.8.0
```

Example `groot.yml` for in-cluster (notify + redaction):

```yaml
output_dir: /out
file_prefix: groot-capture
collection:
  timeout: 20m
  namespaces:
    - kube-system
    - default
  include_node_logs: false
  redact_secrets: true
notify:
  on_failure:
    enabled: true
    min_failed_jobs: 1
  generic:
    enabled: true
    webhook_url: "https://hooks.internal.example/groot"
    body_template: '{"text":"{{summary}}","failed":{{failed}}}'
```

Store webhook URLs and SMTP passwords in a **Secret**, not in git. Mount or inject via `config.grootYml` from CI/CD.

## Flat manifests

See **[k8s/README.md](k8s/README.md)** for the full comparison.

### On-demand (no schedule)

```bash
kubectl apply -f run/deploy/k8s/ondemand-deployment.yaml
kubectl -n groot edit configmap groot-config   # config stays in the cluster
kubectl -n groot exec -it deploy/groot-ondemand -- \
  groot collect --config /config/groot.yml
```

Long-lived pod in namespace `groot`; archives on PVC `groot-out` at `/out`.

### Scheduled CronJob

```bash
# Review and edit run/deploy/k8s/cronjob.yaml (image tag, ConfigMap, schedule)
kubectl apply -f run/deploy/k8s/cronjob.yaml
```

Includes: Namespace `groot`, ServiceAccount, ClusterRole/Binding, ConfigMap, PVC `groot-out`, CronJob `groot-collect`.

Verify:

```bash
kubectl -n groot get cronjob,pvc,configmap
kubectl -n groot create job --from=cronjob/groot-collect groot-manual-test
kubectl -n groot logs job/groot-manual-test
```

Archives appear on the PVC at `/out` inside the job pod.

## RBAC

The bundled ClusterRole grants **read-only** list/get/watch on pods, logs, events, nodes, common workloads, ingresses, and metrics. Tighten for production if you only need namespace-scoped collection.

## Related docs

- [Helm chart README](helm/groot/README.md) — all `values.yaml` keys
- [groot SPEC §9](https://github.com/hrodrig/groot/blob/main/docs/SPECIFICATIONS.md#9-configuration-examples) — config examples
- [groot product README](https://github.com/hrodrig/groot) — CLI install and behavior
- [../README.md](../README.md) — operator index
