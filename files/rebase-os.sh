#!/bin/bash
set -euo pipefail

STAMP="/var/lib/.rebase-complete"

if [ -f "$STAMP" ]; then
  echo "Rebase already completed, nothing to do."
  exit 0
fi

IMAGE="ghcr.io/lthms/elsa-fcos-layer:latest"
echo "Rebasing to ${IMAGE}..."
rpm-ostree rebase ostree-unverified-registry:${IMAGE}
touch "$STAMP"
systemctl reboot
