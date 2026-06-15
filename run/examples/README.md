# Operator config examples

| File | Purpose |
|------|---------|
| [groot-minimal.yml](groot-minimal.yml) | Small starter for bastion or in-cluster `/out` |

For **every config key**, defaults, and notify/upload schema, use the upstream **[configs/groot.yml.sample](https://github.com/hrodrig/groot/blob/main/configs/groot.yml.sample)** and **[SPEC §4–§9](https://github.com/hrodrig/groot/blob/main/docs/SPECIFICATIONS.md)**.

## Deploy contexts

- **Bastion / Docker:** set `output_dir` to your mounted volume (e.g. `/app/out` or `./out`).
- **In-cluster Helm:** set `output_dir: /out` and pass via `--set-file config.grootYml=...` — see [../deploy/README.md](../deploy/README.md).
