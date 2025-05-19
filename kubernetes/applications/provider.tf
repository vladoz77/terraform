terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  # Backend for applicationt
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "vladis-terraform-state"
    region = "ru-central1"
    key    = "kubernetes-application.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# Backend for cluster
data "terraform_remote_state" "k8s_cluster" {
  backend = "s3"
  
  config = {
    bucket = "vladis-terraform-state"
    region = "ru-central1" 
    key    = "kubernetes.tfstate"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "kubectl" {
  config_path = var.kube_config_path
}


provider "vault" {
  address          = "http://127.0.0.1:8200"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.role_id
      secret_id = var.secret_id
    }
  }
}

provider "yandex" {
  token     = data.vault_kv_secret_v2.yc_creds.data["iam_token"]
  cloud_id  = data.vault_kv_secret_v2.yc_creds.data["cloud_id"]
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
  zone      = var.zone
}

  // Настройка секретов
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv"
  name  = "yc-sa-admin"
}

# Backend for network
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


