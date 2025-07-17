terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "vladis-terraform-state"
    region = "ru-central1"
    key    = "kubernetes.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "vladis-terraform-state"
    region = "ru-central1"
    key    = "jenkins.tfstate"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}


// Настройка  vault провайдера
# provider "vault" {
#   address          = "http://127.0.0.1:8200"
#   skip_child_token = true
#   auth_login {
#     path = "auth/approle/login"

#     parameters = {
#       role_id   = var.role_id
#       secret_id = var.secret_id
#     }
#   }
# }
// Настройка секретов
# data "vault_kv_secret_v2" "yc_creds" {
#   mount = "kv"
#   name  = "yc-sa-admin"
# }

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

