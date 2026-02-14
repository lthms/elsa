#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
