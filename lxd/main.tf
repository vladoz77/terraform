
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

# Create volume data
resource "lxd_volume" "data-volume" {
  for_each = local.instances

  name         = "data-${each.key}"
  pool         = lxd_storage_pool.app-data.name
  content_type = "block"

  config = {
    size = "10GB"
  }

}

# Create lxd-profile
resource "lxd_profile" "vm" {
  name = "vm-profile"

  device {
    name = lxd_storage_pool.root.name
    type = "disk"
    properties = {
      path = "/"
      pool = lxd_storage_pool.root.name
      size = "20GB"
    }
  }
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
  source = "./modules/lxd_instance"

  for_each = local.instances

  network_name = module.network.network_name

  instance = {
    profile      = lxd_profile.vm.name
    name         = "ubuntu-${each.key}"
    image        = "ubuntu:22.04"
    ipv4_address = each.value.ipv4_address
    root_name    = lxd_storage_pool.root.name
    cpu          = each.value.cpu
    memory       = each.value.memory
    cloud_init   = file("${path.module}/cloud-init.yaml")
  }
  attached_volume = {
    data = {
      pool = lxd_storage_pool.app-data.name
      name = "data-${each.key}"
    }
  }
  depends_on = [lxd_volume.data-volume]
}
