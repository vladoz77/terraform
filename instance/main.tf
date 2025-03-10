resource "yandex_vpc_network" "network" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = local.network_subnet
  zone           = var.zone
  v4_cidr_blocks = ["172.16.10.0/24"]
  network_id     = yandex_vpc_network.network.id
}

module "yandex-instance" {
  source = "../tf-modules/instance"

  count = 1

  name = "${local.instance_name}-${count.index + 1}"
  zone = local.instance_zone
  platform_id = local.instance_platform_id
  cores = local.instance_core
  memory = local.instance_memory
  core_fraction = local.instance_core_fraction
  ssh = "${var.username}:${var.ssh_key}"
  tags  = local.instance_tag
  network_interfaces = local.instance_network_interface
  boot_disk = local.instance_boot_disk
  labels = {}
}