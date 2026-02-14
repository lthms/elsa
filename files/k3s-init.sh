#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -euo pipefail

IP_FILE="/var/lib/rancher/k3s/.node-ip"
TLS_DIR="/var/lib/rancher/k3s/server/tls"
CA_SRC="/etc/rancher/k3s/tls"
CONFIG_DIR="/etc/rancher/k3s/config.yaml.d"

# Detect public IP on enp1s0
PUBLIC_IP=""
for i in $(seq 1 60); do
  PUBLIC_IP=$(ip -4 -o addr show enp1s0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
  [ -n "$PUBLIC_IP" ] && break
  echo "Waiting for public IP on enp1s0 (attempt $i/60)..."
  sleep 1
done

if [ -z "$PUBLIC_IP" ]; then
  echo "ERROR: Failed to detect public IP on enp1s0 after 60 attempts"
  exit 1
fi

echo "Detected public IP: $PUBLIC_IP"

# Detect VPC IP and interface (10.0.0.x range, brought up by configure-vpc.service)
VPC_IP=""
VPC_IFACE=""
for i in $(seq 1 60); do
  VPC_LINE=$(ip -4 -o addr show 2>/dev/null | grep '10\.0\.0\.' | head -1)
  if [ -n "$VPC_LINE" ]; then
    VPC_IP=$(echo "$VPC_LINE" | awk '{print $4}' | cut -d/ -f1)
    VPC_IFACE=$(echo "$VPC_LINE" | awk '{print $2}')
    break
  fi
  echo "Waiting for VPC IP in 10.0.0.0/24 (attempt $i/60)..."
  sleep 1
done

if [ -z "$VPC_IP" ]; then
  echo "ERROR: Failed to detect VPC IP after 60 attempts"
  exit 1
fi

echo "Detected VPC IP: $VPC_IP on $VPC_IFACE"

# Compare with last known VPC IP
OLD_IP=""
if [ -f "$IP_FILE" ]; then
  OLD_IP=$(cat "$IP_FILE")
fi

if [ "$VPC_IP" != "$OLD_IP" ]; then
  echo "IP changed ($OLD_IP -> $VPC_IP), wiping stale server state"
  rm -rf "$TLS_DIR"
  rm -rf /var/lib/rancher/k3s/server/db
fi

# Always copy CA certs
mkdir -p "$TLS_DIR"
cp "$CA_SRC"/server-ca.crt "$CA_SRC"/server-ca.key "$TLS_DIR"/
cp "$CA_SRC"/client-ca.crt "$CA_SRC"/client-ca.key "$TLS_DIR"/

# Write k3s drop-in config and persist current IP
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/50-vpc.yaml" <<EOF
node-ip: "${VPC_IP}"
tls-san:
  - "${PUBLIC_IP}"
flannel-iface: "${VPC_IFACE}"
EOF
echo "$VPC_IP" > "$IP_FILE"

# Sync auto-deploy manifests into k3s data volume via symlinks
mkdir -p /var/lib/rancher/k3s/server/manifests
find /var/lib/rancher/k3s/server/manifests -maxdepth 1 -type l ! -exec test -e {} \; -delete
for f in /etc/rancher/k3s/manifests/*.yaml; do
  [ -f "$f" ] && ln -sf "$f" /var/lib/rancher/k3s/server/manifests/
done
