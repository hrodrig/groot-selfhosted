# Flat Kubernetes manifests

Self-contained YAML for namespace **`groot`**. Config lives in a **ConfigMap** in the cluster — edit with `kubectl edit`, not from a laptop file.

## Choose a manifest

| File | Mode | When to use |
|------|------|-------------|
| [`ondemand-deployment.yaml`](ondemand-deployment.yaml) | **Deployment** (pod stays up) | Run `groot collect` only when you decide (`kubectl exec`) |
| [`cronjob.yaml`](cronjob.yaml) | **CronJob** (scheduled) | Automatic collection every N hours |

Do **not** apply both CronJob and on-demand Deployment if you only want one mode. Shared resources (namespace, RBAC, ConfigMap, PVC) are compatible; delete the CronJob if you switch:

```bash
kubectl -n groot delete cronjob groot          # Helm release name
kubectl -n groot delete cronjob groot-collect  # flat cronjob.yaml
```

## On-demand (recommended for manual runs)

```bash
kubectl apply -f run/deploy/k8s/ondemand-deployment.yaml
kubectl -n groot rollout status deploy/groot-ondemand
kubectl -n groot get pods
```

**Edit config in the cluster:**

```bash
kubectl -n groot edit configmap groot-config
```

**Collect now:**

```bash
kubectl -n groot exec -it deploy/groot-ondemand -- \
  groot collect --config /config/groot.yml
```

**List archives on the PVC:**

```bash
kubectl -n groot exec -it deploy/groot-ondemand -- ls -lah /out
```

**Copy an archive locally:**

```bash
kubectl -n groot cp groot/$(kubectl -n groot get pod -l app.kubernetes.io/component=ondemand -o jsonpath='{.items[0].metadata.name}'):/out ./groot-archives
```

### Why not `sleep` in the official image?

`ghcr.io/hrodrig/groot` is **distroless** (no shell, no `sleep`). The on-demand manifest uses a minimal **busybox** holder plus an **initContainer** that downloads the matching release binary. Pin the version in the Deployment env `GROOT_VERSION`.

For air-gapped clusters, replace the initContainer with your own image or a pre-populated volume that contains `/opt/groot`.

### Already installed with Helm?

The Helm chart installs a **CronJob**. For on-demand only:

```bash
kubectl -n groot delete cronjob groot
kubectl apply -f run/deploy/k8s/ondemand-deployment.yaml
```

If Helm already created ConfigMap `groot` and PVC `groot`, either `helm uninstall groot -n groot` and apply the full on-demand manifest, or patch the Deployment to reference your existing ConfigMap/PVC names.

### Already installed with Helm + HTTP trigger?

Keep the CronJob. Apply **[groot-trigger](https://github.com/hrodrig/groot-trigger)** `deploy/k8s/always/` only — skip `job-sa/` so you do not fight Helm for ServiceAccount `groot`. Pull secrets belong on this chart (`image.pullSecrets`), not on the trigger Job SA manifest.

## Scheduled (CronJob)

```bash
kubectl apply -f run/deploy/k8s/cronjob.yaml
```

Manual one-shot from the CronJob template:

```bash
kubectl -n groot create job --from=cronjob/groot-collect groot-manual-$(date +%s)
```

**Note:** CronJob `concurrencyPolicy: Forbid` does **not** stop these manual Jobs from overlapping. Upload success lines need `--verbose` on the container args (see comments in `cronjob.yaml`). For S3, add `envFrom` → Secret with `AWS_*` and `upload.s3` in the ConfigMap.

See [../README.md](../README.md) for Helm and RBAC notes.
