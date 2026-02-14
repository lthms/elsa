resource "betteruptime_monitor" "k3s_api" {
  url              = "https://${vultr_instance.control_plane.main_ip}:6443/cacerts"
  monitor_type     = "status"
  check_frequency  = 180
  verify_ssl       = false
  confirmation_period = 180
  regions          = ["eu"]
}

resource "betteruptime_monitor" "agent" {
  count               = var.agent_count
  url                 = vultr_instance.agent[count.index].main_ip
  monitor_type        = "ping"
  check_frequency     = 180
  confirmation_period = 180
  regions             = ["eu"]
}

resource "betteruptime_status_page" "main" {
  company_name = "lthms’ cloud lab"
  company_url  = "https://soap.coffee/~lthms"
  subdomain    = "lthms-cloud-lab"
  timezone     = "Europe/Paris"
}

resource "betteruptime_status_page_resource" "k3s_api" {
  status_page_id = betteruptime_status_page.main.id
  resource_id    = betteruptime_monitor.k3s_api.id
  resource_type  = "Monitor"
  public_name    = "k3s control plane"
}

resource "betteruptime_status_page_resource" "agent" {
  count          = var.agent_count
  status_page_id = betteruptime_status_page.main.id
  resource_id    = betteruptime_monitor.agent[count.index].id
  resource_type  = "Monitor"
  public_name    = "agent ${count.index}"
}
