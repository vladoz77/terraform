terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "2.5.0"  # Должен совпадать с корневым
    }
  }
}