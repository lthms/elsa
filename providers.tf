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
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}
