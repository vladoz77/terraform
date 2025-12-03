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
    key    = "instances/monitoring.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_version = ">=1.9.8"
}

# Настройка провайдера Vault для работы с секретами
provider "vault" {
  address          = "http://10.84.101.123:8200" # Адрес сервера Vault
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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "vladis-terraform-state"
    region = "ru-central1"
    key    = "network.tfstate"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}


module "monitoring" {
  source = "../modules/yc-instance"

  count = var.monitoring.count
  name             = "monitoring-${count.index + 1}"
  zone             = var.zone
  platform_id      = var.platform_id
  cores            = var.monitoring.cpu
  memory           = var.monitoring.memory
  ssh              = "${var.username}:${var.ssh_key}"
  boot_disk        = var.monitoring.boot_disk
  network_interfaces = [
    {
      subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
      nat            = true
      security_group = []
    }
  ]
 create_dns_record = true
 dns_zone_id       = data.terraform_remote_state.network.outputs.zone_id
 dns_records       = var.monitoring.dns_records
}


# Ресурс для генерации динамического inventory-файла Ansible
resource "local_file" "inventory" {
  content = templatefile("../templates/monitoring-inventory.tftpl",
    {
      monitoring     = flatten(module.monitoring[*].public_ips)
      username       = var.username
    }
  )
  filename   = "../../ansible/inventory/monitoring/inventory.ini"
  depends_on = [module.monitoring]
}