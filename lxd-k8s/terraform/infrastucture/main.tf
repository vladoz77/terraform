terraform {
  required_version = ">= 1.9.0"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 3.0.1"
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
  remote {
    name    = "lxd-server-rocky"
    address = "https://rocky:8443"

    client_certificate_file = "/home/vlad/snap/lxd/common/config/client.crt"
    client_key_file          = "/home/vlad/snap/lxd/common/config/client.key"

    server_certificate_fingerprint = "07b430fbac6fd65a15de13f19d0376e31f2c4ba3b1ea844d61997c13d138aa4b"
  }

  default_remote = "lxd-server-rocky"
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

  config = {
    source = each.value.pool_source
  }
}

# Create network
module "network" {
  source = "../modules/lxd_network"
  
  network = {
    name = "lxdbr0"
    ipv4_address = "172.10.10.1/24"
    nat = true
    dhcp = true
    dns_domain = "home.local"
    dns_search = "home.local"
  }
  
}

# Create instance
module "instance" {
  for_each = var.instances

  source = "../modules/lxd_instance"

  network_name = module.network.network_name
  lxd_profile_name = lxd_profile.vm.name
  volumes = each.value.volumes
  instance = {
    root_disk_size    = each.value.root_disk_size
    root_disk_source  = lxd_storage_pool.pools["root-k8s"].name
    name              = "k8s-${each.key}"
    image             = var.lxd_image_os
    ipv4_address      = each.value.ipv4_address
    cpu               = each.value.cpu
    memory            = each.value.memory
    cloud_init        = file("${path.module}/cloud-init.yaml")
  }
  depends_on = [ module.network ]
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