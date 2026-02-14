output "node_ip" {
  value = vultr_instance.control_plane.main_ip
}

output "node_vpc_ip" {
  value = vultr_instance.control_plane.internal_ip
}

output "agent_ips" {
  value = vultr_instance.agent[*].main_ip
}

output "agent_vpc_ips" {
  value = vultr_instance.agent[*].internal_ip
}

output "status_page_url" {
  value = "https://${betteruptime_status_page.main.subdomain}.betteruptime.com"
}
