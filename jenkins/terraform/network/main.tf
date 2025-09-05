# Блок конфигурации Terraform
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"  
      version = "0.134.0"              
    }
  }

  # Конфигурация бэкенда для хранения состояния Terraform в Yandex Object Storage
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"  
    }
    bucket = "vladis-terraform-state"         
    region = "ru-central1"                    
    key    = "network.tfstate"                

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true 
    skip_s3_checksum            = true 
  }

  required_version = ">=1.9.8"  
}

# Настройка провайдера Vault для работы с секретами
provider "vault" {
  address          = "http://127.0.0.1:8200"  # Адрес сервера Vault
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.role_id    
      secret_id = var.secret_id  
    }
  }
}

# Получение секретов из Vault
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv"          
  name  = "yc-sa-admin"
}

# Настройка провайдера Yandex Cloud
provider "yandex" {
  token     = data.vault_kv_secret_v2.yc_creds.data["iam_token"]  
  cloud_id  = data.vault_kv_secret_v2.yc_creds.data["cloud_id"]   
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]  
  zone      = var.zone  
}

module "network" {
  source = "../modules/yc-network"

  network_name = var.network.network_name
  subnet_name = var.network.subnet_name
  ipv4_cidr = [var.network.ipv4_cidr]
  zone = var.zone
}

module "dns" {
  source = "../modules/yc-dns"

  private_networks = module.network.network_id

  create_zone = true
  
  dns_zone = {
    name        = "home-zone"
    description = "Home local zone"
    zone        = "home-local.site."
    public      = true
    deletion_protection = false
  }

  dns_records = var.dns_records

  depends_on = [ module.network ]
}