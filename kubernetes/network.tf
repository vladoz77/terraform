resource "yandex_vpc_network" "network" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = local.subnet_name
  zone           = var.zone
  v4_cidr_blocks = [local.v4_cidr_blocks]
  network_id     = yandex_vpc_network.network.id
}



