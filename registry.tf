data "vultr_container_registry" "base_images" {
  filter {
    name   = "name"
    values = [var.registry_name]
  }
}

output "registry_url" {
  value = "${var.registry_region}.vultrcr.com/${data.vultr_container_registry.base_images.name}"
}

output "registry_user" {
  value     = data.vultr_container_registry.base_images.root_user.username
  sensitive = true
}

output "registry_password" {
  value     = data.vultr_container_registry.base_images.root_user.password
  sensitive = true
}
