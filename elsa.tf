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
  region = var.region
  plan = "vc2-1c-2gb"
  os_id = "391"

  user_data = file("main.ign")

  vpc_ids = [vultr_vpc.cluster.id]

  label = "elsa-control-plane"
  tags = ["elsa"]
  hostname = "elsa-control-plane"
}
