variable "network" {
  description = "Network configurations"
  type = object({
    name = string
    nat = bool
    ipv4_address = string
    ipv6_address = optional(string, "none")
    dhcp = bool
    ipv4_dhcp_ranges = optional(string, "")
    dns_domain = optional(string, "lxd")
    dns_search = optional(string, "lxd")
    raw_dnsmasq = optional(string, "")
  })
  default = {
    name = "lxdbr0"
    nat = true
    dhcp = true
    ipv4_address = "192.168.1.1/24"
    ipv6_address = ""
    ipv4_dhcp_ranges = ""
    dns_domain = "lxd"
    dns_search = "lxd"
    raw_dnsmasq = <<-EOF
      server=1.1.1.1
      server=/dev.local/172.10.10.254
      no-poll
    EOF
  }
}