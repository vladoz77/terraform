# resource "yandex_vpc_network" "network" {
#   name = local.network.network_name
# }

# resource "yandex_vpc_subnet" "subnet" {
#   name           = local.network.network_name
#   zone           = var.zone
#   v4_cidr_blocks = [local.network.v4_cidr_blocks]
#   network_id     = yandex_vpc_network.network.id
# }

resource "yandex_vpc_subnet" "k8s_subnet" {
  name = local.network.network_name
  zone = var.zone
  network_id = data.terraform_remote_state.network.outputs.network_id
  v4_cidr_blocks = [local.network.v4_cidr_blocks]
}


