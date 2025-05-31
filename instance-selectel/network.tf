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

# Создать публичный IP-адрес plane
resource "openstack_networking_floatingip_v2" "plane_public_ip" {
  depends_on = [openstack_networking_router_interface_v2.router_interface_1]
  pool       = "external-network"
  count      = local.plane.count
}

resource "openstack_networking_floatingip_associate_v2" "association_plane" {
  count       = local.plane.count
  port_id     = openstack_networking_port_v2.plane_port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.plane_public_ip[count.index].address
}

# Создать публичный IP-адрес backend
resource "openstack_networking_floatingip_v2" "backend_public_ip" {
  depends_on = [openstack_networking_router_interface_v2.router_interface_1]
  pool       = "external-network"
  count      = local.backend.count
}

resource "openstack_networking_floatingip_associate_v2" "association_backend" {
  count       = local.backend.count
  port_id     = openstack_networking_port_v2.backend_port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.backend_public_ip[count.index].address
}

# Создать публичный IP-адрес backend
resource "openstack_networking_floatingip_v2" "runner_public_ip" {
  depends_on = [openstack_networking_router_interface_v2.router_interface_1]
  pool       = "external-network"
  count      = local.runner.count
}

resource "openstack_networking_floatingip_associate_v2" "association_runner" {
  count       = local.runner.count
  port_id     = openstack_networking_port_v2.runner_port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.runner_public_ip[count.index].address
}