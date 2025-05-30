output "plane_public_ips" {
  value = openstack_networking_floatingip_v2.plane_public_ip[*].address
}

output "backend_public_ips" {
  value = openstack_networking_floatingip_v2.backend_public_ip[*].address
}
