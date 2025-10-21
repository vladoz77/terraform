terraform {
  required_version = ">= 1.9.0"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "2.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "vladis-terraform-state"
    region = "ru-central1"
    key    = "lxd/k8s-infrastucture.tfstate" 

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "lxd" {
  remote {
    address  = "https://172.16.10.1:8443"
  }
}
