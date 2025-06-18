terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "~> 6.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.1.0"
    }
  }

  backend "s3" {
    endpoints                   = { s3 = "https://s3.ru-7.storage.selcloud.ru" }
    key                         = "instance-dev.tfstate"
    region                      = "ru-7"
    bucket                      = "plane-state-bucket"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
  }

  required_version = "~> 1.2"
}



# Провайдер опенстак
provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.selectel_domain_name
  tenant_id   = var.project_id
  user_name   = var.selectel_username
  password    = var.selectel_password
  region      = var.zone_id
}