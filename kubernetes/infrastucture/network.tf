resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = local.network.subnet_name
  zone           = var.zone
  network_id     = local.network.network_id
  v4_cidr_blocks = [local.network.v4_cidr_blocks]
}

resource "yandex_vpc_address" "lb-static-ip" {
  name = "lb-static-ip"
  external_ipv4_address {
    zone_id = var.zone
  }
}

