# k3s bootstrap token mismatch after major version upgrade

## Context

After bumping k3s from **v1.31.4** to **v1.35.1** (via the OCI layer image),
the control plane entered a crash loop with:

```
failed to bootstrap cluster data: bootstrap data already found and encrypted with different token
```

The token in `/etc/rancher/k3s/config.yaml` had **not** changed.

## Root cause

k3s encrypts bootstrap data at rest using AES-256-GCM with a key derived from
the server token via PBKDF2. Between v1.31 and v1.35, the way k3s derives that
key from the raw token string changed (likely how it extracts the "passphrase
portion" from the full `K10<hash>::server:<password>` cluster token format).

Same token string, different derived key, so the new binary cannot decrypt the
old bootstrap data.

This class of issue has occurred before (k3s-io/k3s#4640, GHSA-cxm9-4m6p-24mc).
Some past transitions included auto-re-encryption logic, but the v1.31 -> v1.35
jump apparently does not.

## Resolution

Destroyed and recreated the cluster. Since the infra is fully declarative (CA
certs are pre-generated, manifests are auto-deployed via symlinks), this was the
cleanest path.

## Possible alternatives (not tested)

- **Stepping-stone upgrades**: go through v1.32, v1.33, v1.34 one at a time;
  an intermediate version might handle the migration.
- **Wipe just the DB**: `rm -rf /var/lib/rancher/k3s/server/db` on the node,
  keeping the persistent volume but letting k3s re-bootstrap.
- **Roll back**: revert the Containerfile to v1.31.4 as a stopgap.

## References

- https://github.com/k3s-io/k3s/issues/4640
- https://github.com/k3s-io/k3s/security/advisories/GHSA-cxm9-4m6p-24mc
- https://docs.k3s.io/cli/token
