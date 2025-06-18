# Создадим приватную сеть и подсеть⁠
resource "openstack_networking_network_v2" "private-network" {
  name           = "private-network"
  admin_state_up = "true"
}

# Создадим подсеть
resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.private-network.id
  cidr       = local.network.cidr
}

# Создадим роутер
resource "openstack_networking_router_v2" "router_1" {
  name                = "router"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

# Привяжем роутер к подсети
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

