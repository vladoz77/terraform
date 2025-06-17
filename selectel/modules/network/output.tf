output "network_id" {
  value = openstack_networking_network_v2.network.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.subnet.id
}

output "port_id" {
  value = openstack_networking_port_v2.port.id
}