
resource "lxd_storage_pool" "root-k8s" {
  name   = "root-k8s"
  driver = "dir"
  source = "/mnt/lxd-pools/root-k8s"
}

# Create pool app-data
resource "lxd_storage_pool" "data-k8s" {
  name   = "pool-k8s"
  driver = "dir"
  source = "/mnt/lxd-pools/pool-k8s"
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
  storage_pool = lxd_storage_pool.data-k8s.name

  instance = {
    root_pool_size = "30GB"
    root_pool      = lxd_storage_pool.root-k8s.name
    name           = "k8s-${each.key}"
    image          = "fedora42"
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