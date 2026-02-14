# elsa

## Deployment

NEVER run `make deploy`, `make destroy`, or `terraform apply`/`terraform destroy` yourself. Deployment is always done by the user.

## Commit messages

Follow the pattern: `Topic - short description of the change`. Examples:
- `OCI layered base image - replace runtime downloads with prebaked image`
- `k3s agent nodes - scalable agents joining the cluster over VPC`
- `Housekeeping - rename main.bu/elsa.tf ahead of agent node work`

## k3s auto-deploy manifests

Custom k8s manifests are placed in `/etc/rancher/k3s/manifests/` via Butane and symlinked into `/var/lib/rancher/k3s/server/manifests/` by `k3s-init.sh`. Dangling symlinks are cleaned up on boot, so removing a manifest from the Butane config is enough to undeploy it.

k3s's own manifests (coredns, traefik, etc.) are real files in the same directory and are never touched by this mechanism.
