# elsa

## Tooling philosophy

Prefer off-the-shelf tools over custom scripts. Before writing makefile targets, shell helpers, or bespoke download logic, check whether an existing tool already solves the problem. Packaging in mise and support by Renovate are strong signals in favor of adopting a tool.

## kubectl

Always use `kubectl --kubeconfig elsa.yaml` (in the repo root). The default `~/.kube/config` is not used for this cluster.

## Deployment

NEVER run `make deploy`, `make destroy`, or `terraform apply`/`terraform destroy` yourself. Deployment is always done by the user.

Each deployment recreates cloud instances and costs money. Before proposing any configuration change (CLI flags, Helm values, environment variables, etc.), ALWAYS verify the exact syntax against official documentation first. Do not guess flag names or assume conventions from other tools. A failed deploy because of a typo or nonexistent flag wastes a full cycle.

## Commit messages

Follow the pattern: `Topic - short description of the change`. Examples:
- `OCI layered base image - replace runtime downloads with prebaked image`
- `k3s agent nodes - scalable agents joining the cluster over VPC`
- `Housekeeping - rename main.bu/elsa.tf ahead of agent node work`

## k3s auto-deploy manifests

Custom k8s manifests are placed in `/etc/rancher/k3s/manifests/` via Butane and symlinked into `/var/lib/rancher/k3s/server/manifests/` by `k3s-init.sh`. Dangling symlinks are cleaned up on boot, so removing a manifest from the Butane config is enough to undeploy it.

k3s's own manifests (coredns, traefik, etc.) are real files in the same directory and are never touched by this mechanism.
