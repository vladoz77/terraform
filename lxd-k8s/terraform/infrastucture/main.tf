resource "lxd_profile" "vm" {
  name = var.lxd_profile_name
}


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
    image          = each.value.image
    type           = each.value.type
    ipv4_address   = each.value.ipv4_address
    cpu            = each.value.cpu
    memory         = each.value.memory
    cloud_init     =  file("${path.module}/cloud-init.yaml")
  }

  volumes = each.value.volumes
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/k8s-inventory.tftpl",
    {
      masters = {
        for key, value in var.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "master")
      }
      workers = {
        for key, value in var.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "worker")
      }
    }
  )
  filename   = "../../ansible/inventory.ini"
  depends_on = [module.instance]
}