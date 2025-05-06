resource "yandex_vpc_network" "network" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = local.network_subnet
  zone           = var.zone
  v4_cidr_blocks = ["172.16.10.0/24"]
  network_id     = yandex_vpc_network.network.id
}

