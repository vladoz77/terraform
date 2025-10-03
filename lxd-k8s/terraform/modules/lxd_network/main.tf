resource "lxd_network" "network" {
  name = var.network.network_name

  config = {
    "ipv4.address" = var.network.ipv4_address
    "ipv4.nat"     = var.network.nat ? "true" : "false"
    "ipv4.dhcp"    = var.network.dhcp ? "true" : "false"
    "ipv6.address" = "none"
  }
}