variable "network" {
  description = "Network config"
  type = object({
    network_name = string
    ipv4_address = string
    nat          = optional(bool, true)
    dhcp         = optional(bool, true)
  })
}