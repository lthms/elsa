#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -euo pipefail

# Wait for API
for i in $(seq 1 60); do
  k3s kubectl get nodes &>/dev/null && break
  sleep 2
done

# Delete stale agent node objects from the previous deploy. Agents will
# re-register with fresh node objects carrying correct ExternalIPs.
k3s kubectl delete nodes \
  -l '!node-role.kubernetes.io/control-plane' \
  --ignore-not-found

rm -f /var/lib/.fresh-deploy
