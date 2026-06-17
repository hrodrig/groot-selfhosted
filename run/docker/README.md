# Docker and Podman — bastion collection

Run the published **GROOT** image against a cluster using a host **kubeconfig**. For building the image from source, see upstream [groot](https://github.com/hrodrig/groot) (`Dockerfile`, GoReleaser).

**Image:** `ghcr.io/hrodrig/groot:0.8.0`

## Pull

```bash
docker pull ghcr.io/hrodrig/groot:0.8.0
```

## Run with kubeconfig and output directory

Mount your kubeconfig read-only and a host directory for archives (`output_dir` in config defaults to `./out`; override in your config file).

```bash
mkdir -p ./out

docker run --rm \
  -v "$HOME/.kube:/home/nonroot/.kube:ro" \
  -v "$(pwd)/out:/app/out" \
  -v "$(pwd)/groot.yml:/app/groot.yml:ro" \
  ghcr.io/hrodrig/groot:0.8.0 \
  collect --config /app/groot.yml
```

Minimal **`groot.yml`** for bastion runs: see [../examples/groot-minimal.yml](../examples/groot-minimal.yml) (set `output_dir: /app/out` when using the mount above).

## Podman (rootless)

```bash
podman run --rm \
  -v "$HOME/.kube:/home/nonroot/.kube:ro" \
  -v "$(pwd)/out:/app/out" \
  -v "$(pwd)/groot.yml:/app/groot.yml:ro" \
  ghcr.io/hrodrig/groot:0.8.0 \
  collect --config /app/groot.yml
```

## Local image from upstream source

For development only (not required for production):

```bash
git clone https://github.com/hrodrig/groot.git
cd groot
make docker-build

docker run --rm \
  -v "$HOME/.kube:/home/nonroot/.kube:ro" \
  -v "$(pwd)/out:/app/out" \
  groot:local collect --config /path/to/groot.yml
```

The upstream image is **distroless nonroot** — see [groot README — Features](https://github.com/hrodrig/groot#features).

## In-cluster instead?

If GROOT should run **inside** the cluster on a schedule, use [../deploy/README.md](../deploy/README.md) (Helm CronJob or flat manifests).

## Security

Archives may contain sensitive data. Enable `collection.redact_secrets` in config. Restrict access to `./out` and kubeconfig. See upstream [Security note](https://github.com/hrodrig/groot#security-note).
