provider "vultr" {}

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
