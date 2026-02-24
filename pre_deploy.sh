#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Drain agent nodes that are about to be destroyed.
# All arguments are forwarded to terraform plan to generate a temporary
# plan file used only for inspection.

set -euo pipefail

KUBECONFIG="elsa.yaml"
PLANFILE=".tfplan.$$"

cleanup() { rm -f "$PLANFILE"; }
trap cleanup EXIT

terraform plan "$@" -out="$PLANFILE" >/dev/null

plan_json=$(terraform show -json "$PLANFILE")

# Build a compact summary of every resource change.
summary=$(echo "$plan_json" \
  | jq -r '
      .resource_changes[]
      | select(.change.actions != ["no-op"])
      | "\(.change.actions | join(","))  \(.address)"
    ')

# Extract hostnames of agent nodes being deleted.
hostnames=$(echo "$plan_json" \
  | jq -r '
      .resource_changes[]
      | select(.type == "vultr_instance")
      | select(.change.actions | index("delete"))
      | .change.before.hostname
      | select(startswith("elsa-agent-"))
    ')

if [ -z "$summary" ]; then
  echo "No pending changes."
  exit 0
fi

echo "Pending changes:"
echo "$summary" | while IFS= read -r line; do
  echo "  $line"
done

if [ -n "$hostnames" ] && [ -f "$KUBECONFIG" ]; then
  echo ""
  echo "Agent nodes to drain before apply:"
  for node in $hostnames; do
    echo "  $node"
  done
fi

echo ""
read -rp "Proceed? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

if [ -n "$hostnames" ] && [ -f "$KUBECONFIG" ]; then
  # Drain all nodes in parallel to avoid rescheduling pods onto nodes
  # that are about to be drained themselves. Node objects are deleted
  # later by the new agent instances on boot (via agent-init.sh).
  pids=()
  for node in $hostnames; do
    (
      echo "Draining $node..."
      kubectl --kubeconfig "$KUBECONFIG" drain "$node" \
        --ignore-daemonsets --delete-emptydir-data --force --timeout=120s || true
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid"
  done
fi
