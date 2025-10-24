terraform {
  required_version = ">= 1.0"

  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}