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
  type = string
  description = ""
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

variable "agent_count" {
  type    = number
  default = 0
}

