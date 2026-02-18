# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

resource "vultr_vpc" "cluster" {
  region         = var.region
  description    = "elsa-vpc"
  v4_subnet      = "10.0.0.0"
  v4_subnet_mask = 24
}

resource "vultr_block_storage" "control_plane_storage" {
  size_gb = var.control_plane_storage_gb
  region = var.region
  attached_to_instance = vultr_instance.control_plane.id
}

resource "vultr_instance" "control_plane" {
  region  = var.region
  plan    = var.control_plane_plan
  os_id   = "391"

  user_data = file("control_plane.ign")

  vpc_ids = [vultr_vpc.cluster.id]

  label    = "elsa-control-plane"
  tags     = ["elsa"]
  hostname = "elsa-control-plane"
}

resource "vultr_instance" "agent" {
  count   = var.agent_count
  region  = var.region
  plan    = var.agent_plan
  os_id   = "391"

  user_data = replace(
    replace(file("agent.ign"), "__VPC_STATIC_IP__", "10.0.0.${20 + count.index}"),
    "__K3S_SERVER_IP__", var.control_plane_vpc_ip
  )

  vpc_ids = [vultr_vpc.cluster.id]

  label    = "elsa-agent-${count.index}"
  tags     = ["elsa"]
  hostname = "elsa-agent-${count.index}"
}

