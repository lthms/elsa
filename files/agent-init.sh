#!/bin/bash
set -euo pipefail

CONFIG_DIR="/etc/rancher/k3s/config.yaml.d"

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

# Generate a stable node password from hostname so reprovisions
# don't get rejected by the control plane
mkdir -p /etc/rancher/node
hostname -s | sha256sum | cut -d' ' -f1 > /etc/rancher/node/password

# Write k3s drop-in config
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/50-vpc.yaml" <<EOF
node-ip: "${VPC_IP}"
flannel-iface: "${VPC_IFACE}"
EOF
