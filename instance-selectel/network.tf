# Создадим приватную сеть и подсеть⁠
resource "openstack_networking_network_v2" "private-network" {
  name           = "private-network"
  admin_state_up = "true"

  depends_on = [
    selectel_iam_serviceuser_v1.instance-sa
  ]
}

# Создадим подсеть
resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.private-network.id
  cidr       = local.network.cidr
}

# Получаем внешнюю сеть
data "openstack_networking_network_v2" "external_network" {
  external = true
  depends_on = [
    selectel_iam_serviceuser_v1.instance-sa
  ]
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

# Создадим порты для облачных серверов
resource "openstack_networking_port_v2" "port" {
  name               = "port"
  network_id         = openstack_networking_network_v2.private-network.id
  admin_state_up     = "true"
  count = local.count

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.subnet_1.id
  }
}

# Создать публичный IP-адрес
resource "openstack_networking_floatingip_v2" "public_ip" {
  depends_on = [ openstack_networking_router_interface_v2.router_interface_1 ]
  pool = "external-network"
  count = local.count
}

resource "openstack_networking_floatingip_associate_v2" "association_1" {
  count = local.count
  port_id     = openstack_networking_port_v2.port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.public_ip[count.index].address
}