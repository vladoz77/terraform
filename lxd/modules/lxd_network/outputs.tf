output "network_name" {
  description = "Network name"
  value = lxd_network.network.name
}

output "ipv4_cidr" {
  value = var.network.ipv4_address
}