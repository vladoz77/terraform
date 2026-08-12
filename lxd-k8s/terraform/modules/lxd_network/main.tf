resource "lxd_network" "network" {
  name = var.network.name

  config = {
    "ipv4.address" = var.network.ipv4_address
    "ipv6.address" = var.network.ipv6_address 
    "ipv4.nat"     = tostring(var.network.nat)
    "ipv4.dhcp"    = tostring(var.network.dhcp)
    "ipv4.dhcp.ranges" = var.network.ipv4_dhcp_ranges
    "dns.domain"   = var.network.dns_domain
    "dns.search"   = var.network.dns_search
    "raw.dnsmasq"  = var.network.raw_dnsmasq
  }
}