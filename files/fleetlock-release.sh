#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -euo pipefail

FLEETLOCK_URL="http://10.43.0.100:8080"
MACHINE_ID=$(cat /etc/machine-id)

for i in $(seq 1 84); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$FLEETLOCK_URL/v1/steady-state" \
    -H "fleet-lock-protocol: true" \
    -d "{\"client_params\":{\"id\":\"$MACHINE_ID\",\"group\":\"default\"}}") || true
  if [ "$HTTP_CODE" = "200" ]; then
    echo "FleetLock released."
    exit 0
  fi
  echo "Waiting for FleetLock server (attempt $i/84)..."
  sleep 5
done
echo "WARNING: Failed to release FleetLock after 84 attempts"
exit 1
