terraform { 
  cloud { 
    organization = "lthms" 

    workspaces { 
      name = "elsa" 
    } 
  } 

  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.28.1"
    }
    betteruptime = {
      source  = "BetterStackHQ/better-uptime"
      version = "~> 0.11"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

provider "betteruptime" {
  api_token = var.betterstack_api_token
}
