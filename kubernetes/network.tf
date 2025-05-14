resource "yandex_vpc_subnet" "k8s_subnet" {
  name = local.network.subnet_name
  zone = var.zone
  network_id = local.network.network_id
  v4_cidr_blocks = [local.network.v4_cidr_blocks]
}


