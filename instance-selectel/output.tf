output "public_ips" {
  value = openstack_networking_floatingip_v2.public_ip[*].address
}