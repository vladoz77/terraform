terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "2.5"

    }
  }
}

provider "lxd" {}