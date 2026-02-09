resource "vultr_vpc" "cluster" {
  region         = var.region
  description    = "elsa-vpc"
  v4_subnet      = "10.0.0.0"
  v4_subnet_mask = 24
}

resource "vultr_block_storage" "control_plane_storage" {
  size_gb = 10
  region = var.region
  attached_to_instance = vultr_instance.control_plane.id
}

resource "vultr_instance" "control_plane" {
  region  = var.region
  plan    = "vc2-1c-2gb"
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
  plan    = "vc2-1c-2gb"
  os_id   = "391"

  user_data = replace(file("agent.ign"), "__K3S_SERVER_IP__", vultr_instance.control_plane.internal_ip)

  vpc_ids = [vultr_vpc.cluster.id]

  label    = "elsa-agent-${count.index}"
  tags     = ["elsa"]
  hostname = "elsa-agent-${count.index}"
}
