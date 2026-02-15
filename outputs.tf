# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
