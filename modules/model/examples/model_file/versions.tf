terraform {
  required_version = ">= 1.9.0"

  required_providers {
    utils = {
      source  = "netascode/utils"
      version = ">= 1.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2"
    }
  }
}
