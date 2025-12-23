resource "lxd_storage_pool" "root" {
  name   = "root-1"
  driver = "dir"
  source = "/mnt/lxd-pools/root-1"
}

resource "lxd_storage_pool" "data" {
  name   = "data-1"
  driver = "dir"
  source = "/mnt/lxd-pools/pool-2"
}

# Create network
module "network" {
  source = "./modules/lxd_network"

  network = {
    network_name = var.network.name
    ipv4_address = var.network.ipv4_address
  }
}

# Create instance
module "instance" {
  source = "./modules/lxd_instance"

  network_name = module.network.network_name

  instance = {
    root_disk_size = var.instance.root_disk_size
    root_pool_name = lxd_storage_pool.root.name
    name           = var.instance.name
    image          = var.instance.image
    type           = var.instance.type
    ipv4_address   = var.instance.ipv4_address
    cpu            = var.instance.cpu
    memory         = var.instance.memory
    cloud_init     = file("${path.module}/cloud-init.yaml")
  }

  additional_volumes = {
    data1 = {
      size = "10GB"
      pool = lxd_storage_pool.data.name
    }
    data2 = {
      size = "15GB"
      pool = lxd_storage_pool.data.name
    }
  }
}
