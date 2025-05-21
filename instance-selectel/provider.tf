terraform {
  required_providers {
    selectel  = {
      source  = "selectel/selectel"
      version = "~> 6.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
  }
}

provider "selectel" {
  domain_name = "434641"
  username    = "Vlad"
  password    = "!QAZ2wsx#EDC4rfv"
  auth_region = "ru-9"
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
}