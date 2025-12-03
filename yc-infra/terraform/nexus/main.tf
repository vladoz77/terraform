terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"
}

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

data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv"
  name  = "yc-sa-admin"
}

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

module "nexus" {
  source = "../modules/yc-instance"

  count = var.nexus.count

  name        = "${var.nexus.instance_name}-${count.index + 1}"
  zone        = var.zone
  platform_id = var.platform_id
  cores       = var.nexus.cpu
  memory      = var.nexus.memory
  ssh         = "${var.username}:${var.ssh_key}"
  boot_disk   = var.nexus.boot_disk
  network_interfaces = [
    {
      subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
      nat            = true
      security_group = []
    }
  ]
  create_dns_record = true
  dns_records       = var.nexus.dns_records
  dns_zone_id       = data.terraform_remote_state.network.outputs.zone_id
}

resource "local_file" "inventory" {
  content = templatefile("../templates/nexus-inventory.tftpl",
    {
      nexus    = flatten(module.nexus[*].public_ips)
      username = var.username
    }
  )
  filename   = "../../ansible/inventory/nexus/inventory.ini"
  depends_on = [module.nexus]
}