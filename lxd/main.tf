
resource "lxd_storage_pool" "root" {
  name   = "root-1"
  driver = "dir"
  source = "/mnt/lxd-pools/root-1"
}

# Create pool app-data
resource "lxd_storage_pool" "app-data" {
  name   = "app-data"
  driver = "dir"
  source = "/mnt/lxd-pools/pool-1"
}

# Create network
module "network" {
  source = "./modules/lxd_network"

  network = {
    network_name = "lxdbr0"
    ipv4_address = "192.168.200.1/24"
  }
}

# Create instance
module "instance" {
  for_each = local.instances

  source = "./modules/lxd_instance"

  network_name = module.network.network_name
  storage_pool = lxd_storage_pool.app-data.name

  instance = {
    root_pool_size = "20GB"
    root_pool      = lxd_storage_pool.root.name
    name           = "ubuntu-${each.key}"
    image          = "ubuntu:22.04"
    type           = "virtual-machine"
    ipv4_address   = each.value.ipv4_address
    cpu            = each.value.cpu
    memory         = each.value.memory
    cloud_init     = file("${path.module}/cloud-init.yaml")
  }

  volumes = each.value.volumes
}
