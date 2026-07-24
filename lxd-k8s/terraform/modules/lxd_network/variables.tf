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
  })
  default = {
    name = "lxdbr0"
    nat = true
    dhcp = true
    ipv4_address = "192.168.1.1/24"
    ipv6_address = ""
  }
}