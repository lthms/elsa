#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

set -euo pipefail

META=$(curl -sf http://169.254.169.254/v1.json)

VPC_IP=$(echo "$META" | jq -r '.interfaces[] | select(.["network-type"]=="private") | .ipv4.address')
VPC_MASK=$(echo "$META" | jq -r '.interfaces[] | select(.["network-type"]=="private") | .ipv4.netmask')
VPC_MAC=$(echo "$META" | jq -r '.interfaces[] | select(.["network-type"]=="private") | .mac')

# Convert dotted netmask to CIDR prefix length
IFS=. read -r a b c d <<< "$VPC_MASK"
BITS=$(( (a<<24) + (b<<16) + (c<<8) + d ))
PREFIX=0
while [ $BITS -ne 0 ]; do
  PREFIX=$(( PREFIX + (BITS & 1) ))
  BITS=$(( BITS >> 1 ))
done

# Find the interface with this MAC address
DEV=$(ip -o link | awk -F': ' -v mac="$VPC_MAC" 'tolower($0) ~ mac {print $2}')

# Get MTU from metadata (Vultr VPCs typically use 1450)
VPC_MTU=$(echo "$META" | jq -r '.interfaces[] | select(.["network-type"]=="private") | .mtu // "1450"')

echo "Configuring $DEV ($VPC_MAC) with $VPC_IP/$PREFIX mtu $VPC_MTU"
nmcli con add type ethernet con-name vpc ifname "$DEV" \
  ipv4.method manual ipv4.addresses "$VPC_IP/$PREFIX" \
  ipv4.never-default yes \
  ethernet.mtu "$VPC_MTU"
nmcli con up vpc
