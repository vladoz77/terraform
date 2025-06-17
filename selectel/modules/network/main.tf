terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 3.1.0"
    }
  }
}

# Создадим приватную сеть и подсеть⁠
resource "openstack_networking_network_v2" "network" {
  name           = var.network_name
  admin_state_up = "true"
}

# Создадим подсеть
resource "openstack_networking_subnet_v2" "subnet" {
  name       = var.subnet_name
  network_id = openstack_networking_network_v2.network.id
  cidr       = var.cidr
}

# Создадим порты 
resource "openstack_networking_port_v2" "port" {
  name           = "port"
  network_id     = openstack_networking_network_v2.network.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

# Создадим роутер
resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  external_network_id = var.external_network_id
}

# Привяжем роутер к подсети
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

