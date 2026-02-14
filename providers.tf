# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
      version = "2.29.1"
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
