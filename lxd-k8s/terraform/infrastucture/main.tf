terraform {
  required_version = ">= 1.9.0"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 2.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.6.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
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
  generate_client_certificates = true
  accept_remote_certificate    = true
  remote {
    name     = "lxd-server-1"
    address  = "https://localhost:8443"
    password = "supersecret"
    default  = true
  }
}

# Create LXD profile
resource "lxd_profile" "vm" {
  name = var.lxd_profile_name
}

# Create storage pools
resource "lxd_storage_pool" "pools" {
  for_each = var.pools

  name   = each.key
  driver = each.value.pool_driver
  source = each.value.pool_source
}

# Create network
module "network" {
  source = "../modules/lxd_network"

  network = {
    network_name = "lxdbr0"
    ipv4_address = "192.168.200.1/24"
  }
}

# Create instance
module "instance" {
  for_each = var.instances

  source = "../modules/lxd_instance"

  network_name = module.network.network_name
  lxd_profile_name = lxd_profile.vm.name
  default_storage_pool = ""

  instance = {
    root_disk_size = each.value.root_disk_size
    root_pool_name = lxd_storage_pool.pools["root-k8s"].name
    name           = "k8s-${each.key}"
    image          = var.lxd_image_os
    type           = each.value.type
    ipv4_address   = each.value.ipv4_address
    cpu            = each.value.cpu
    memory         = each.value.memory
    cloud_init     =  file("${path.module}/cloud-init.yaml")
  }

  volumes = each.value.volumes
}

# Generate Ansible inventory file
resource "local_file" "inventory" {
  content = templatefile("${path.module}/k8s-inventory.tftpl",
    {
      masters = local.masters_ip
      workers = local.workers_ip
    }
  )
  filename   = "../../ansible/inventories/${var.environment}/inventory.ini"
  depends_on = [module.instance]
}