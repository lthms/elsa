#!/bin/bash
set -euo pipefail

FLEETLOCK_URL="http://10.43.0.100:8080"
MACHINE_ID=$(cat /etc/machine-id)

echo "Checking for OS image upgrade..."
rc=0
rpm-ostree upgrade --unchanged-exit-77 || rc=$?

if [ "$rc" -eq 77 ]; then
  echo "System is up to date."
  exit 0
elif [ "$rc" -ne 0 ]; then
  echo "ERROR: rpm-ostree upgrade failed (exit $rc)"
  exit 1
fi

echo "Upgrade staged. Acquiring reboot lock..."
while true; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$FLEETLOCK_URL/v1/pre-reboot" \
    -H "fleet-lock-protocol: true" \
    -d "{\"client_params\":{\"id\":\"$MACHINE_ID\",\"group\":\"default\"}}") || true
  if [ "$HTTP_CODE" = "200" ]; then
    echo "Lock acquired. Rebooting..."
    systemctl reboot
    exit 0
  fi
  echo "Lock not available (HTTP $HTTP_CODE), retrying in 30s..."
  sleep 30
done
