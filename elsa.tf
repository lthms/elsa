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

  label = "elsa-control-plane"
  tags = ["elsa"]
  hostname = "elsa-control-plane"
}
