
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
  source = "../modules/lxd_network"

  network = {
    network_name = "lxdbr0"
    ipv4_address = "192.168.200.1/24"
  }
}

# Create instance
module "instance" {
  for_each = local.instances

  source = "../modules/lxd_instance"

  network_name = module.network.network_name
  storage_pool = lxd_storage_pool.app-data.name

  instance = {
    root_pool_size = "30GB"
    root_pool      = lxd_storage_pool.root.name
    name           = "k8s-${each.key}"
    image          = "57ac3dd8f816"
    type           = "virtual-machine"
    ipv4_address   = each.value.ipv4_address
    cpu            = each.value.cpu
    memory         = each.value.memory
    cloud_init     = file("${path.module}/cloud-init.yaml")
  }

  volumes = each.value.volumes
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/k8s-inventory.tftpl",
    {
      masters = {
        for key, value in local.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "master")
      }
      workers = {
        for key, value in local.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "worker")
      }
    }
  )
  filename   = "../../ansible/inventory.ini"
  depends_on = [module.instance]
}