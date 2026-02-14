# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

variable "region" {
  type = string
  description = "Region to deploy this stack"
}

variable "vultr_api_key" {
  type = string
  description = "API key used to configure the provider"
  sensitive = true
}

variable "betterstack_source_token" {
  type = string
  description = "Source token for Betterstack ingestion"
  sensitive = true
}

variable "betterstack_ingesting_host" {
  type        = string
  description = "Host endpoint for Betterstack log ingestion"
}

variable "k3s_token" {
  type = string
  description = "Token for k3s agents to join the cluster"
  sensitive = true
}

variable "betterstack_api_token" {
  type        = string
  description = "API token for Betterstack Uptime provider"
  sensitive   = true
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key for the core user"
}

variable "status_page_company_name" {
  type        = string
  description = "Company name shown on the Betterstack status page"
}

variable "status_page_company_url" {
  type        = string
  description = "Company URL shown on the Betterstack status page"
}

variable "status_page_subdomain" {
  type        = string
  description = "Subdomain for the Betterstack status page"
}

variable "status_page_timezone" {
  type        = string
  description = "Timezone for the Betterstack status page"
}

variable "acme_email" {
  type        = string
  description = "Email address for Let's Encrypt ACME registration"
}

variable "control_plane_plan" {
  type        = string
  description = "Vultr instance plan for the control plane node"
  default     = "vc2-1c-2gb"
}

variable "agent_plan" {
  type        = string
  description = "Vultr instance plan for agent nodes"
  default     = "vc2-1c-2gb"
}

variable "control_plane_storage_gb" {
  type        = number
  description = "Block storage size in GB for the control plane"
  default     = 10
}

variable "agent_count" {
  type        = number
  description = "Number of k3s agent nodes to deploy"
  default     = 0
}

