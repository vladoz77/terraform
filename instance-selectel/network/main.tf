# Получаем внешнюю сеть
data "openstack_networking_network_v2" "external_network" {
  name = "external-network"
}

# Получаем внешние подсети
data "openstack_networking_subnet_ids_v2" "external_subnet" {
  network_id = data.openstack_networking_network_v2.external_network.id
}

module "network" {
  source = "../modules/network"
  
  network_name        = network
  cidr                = "172.16.10.0/24"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}