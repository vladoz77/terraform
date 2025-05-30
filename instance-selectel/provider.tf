terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "~> 6.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.1.0"
    }
  }
  required_version = "~> 1.2"
}

# Провайдер опенстак
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = local.selectel_domain_name
  tenant_id   = local.project_id
  user_name   = var.selectel_username
  password    = var.selectel_password
  region      = var.zone_id
}

