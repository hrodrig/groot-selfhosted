# Security policy

## Scope

This repository holds **operator** material for GROOT: Helm chart, Kubernetes manifests, Docker/Podman runbooks, and example configs. It does **not** ship the GROOT binary or collector source.

| Report here (groot-selfhosted) | Report upstream ([groot](https://github.com/hrodrig/groot)) |
|----------------------------------|-------------------------------------------------------------|
| Overly broad RBAC in bundled manifests | Bugs in **`groot collect`**, client-go handling, notify/upload code |
| Example configs or docs that encourage unsafe secrets handling | Vulnerabilities in the published **`ghcr.io/hrodrig/groot`** image build |
| Misleading deployment guidance with security impact | CodeQL / dependency issues in the Go product |

Collected archives may contain cluster secrets. Treat PVC mounts, output volumes, and webhook URLs as sensitive — see [groot README → Security note](https://github.com/hrodrig/groot#security-note).

## Host / kernel notes

Operators own the **bastion, CronJob nodes, and worker kernels**. Keep Linux hosts patched.

**[CVE-2026-98432](https://nvd.nist.gov/vuln/detail/CVE-2026-98432)** (Linux IPv4 TCP UAF; public PoCs abuse MPTCP listeners):

- The GROOT CLI / CronJob image has **no production listen socket** — see [groot#55](https://github.com/hrodrig/groot/issues/55). App-level MPTCP listen mitigations are **not** required for typical `groot collect` deployments.
- Still patch the **host kernel** (and any other Go listeners on the same machine). That is the primary fix ([Go announce](https://groups.google.com/g/golang-announce/c/PCoQcdxoScw)).
- If you later run a long-lived HTTP surface on these hosts (e.g. [groot-trigger](https://github.com/hrodrig/groot-trigger)), keep hosts current and follow that project’s listener guidance.

## Supported versions

We support the **latest release** tagged on **`main`** of this repo (manifests and docs), used with a current **[groot](https://github.com/hrodrig/groot/releases)** release. Versions follow [semantic versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

| Version | Supported |
| ------- | --------- |
| Latest **groot-selfhosted** release | Yes |
| Latest **groot** release (binary/image) | Yes — see [groot SECURITY.md](https://github.com/hrodrig/groot/blob/main/SECURITY.md) |
| Older releases | No — upgrade both repos when possible |

Security fixes to manifests or runbooks ship as patch releases of **groot-selfhosted** when applicable.

## Reporting a vulnerability

**Do not open a public issue** for undisclosed security vulnerabilities.

- **GROOT binary, collector, container image, notify/upload:**  
  [Report a vulnerability on groot](https://github.com/hrodrig/groot/security/advisories/new) (preferred) — see [groot SECURITY.md](https://github.com/hrodrig/groot/blob/main/SECURITY.md).

- **Helm chart, Kubernetes manifests, operator runbooks in this repo:**  
  [Report a vulnerability on groot-selfhosted](https://github.com/hrodrig/groot-selfhosted/security/advisories/new) (preferred).

- **Alternatively:** Contact the maintainer via [github.com/hrodrig](https://github.com/hrodrig). Include description, steps to reproduce, affected paths/versions, and impact.

## What to expect

- Acknowledgment as soon as practical.
- Investigation and, for accepted reports, a fix or mitigation in the appropriate repo.
- Coordinated disclosure and credit if you want it; anonymous reports respected.
- Brief explanation if we decline or defer (e.g. operator misconfiguration outside repo defaults).

Thank you for helping keep GROOT deployments safe.
