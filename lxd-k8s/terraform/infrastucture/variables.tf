variable "environment" {
  type        = string
  description = "Type of environment"
}

variable "lxd_server_address" {
  type        = string
  description = "LXD server address"
  default     = "https://rocky.homelab.local:8443"
}

variable "lxd_server_cert_fingerprint" {
  type        = string
  description = "LXD server certificate fingerprint"
}

variable "lxd_profile_name" {
  default = "instance"
  type    = string
}

variable "lxd_image_os" {
  default = ""
  type    = string
}

variable "network" {
  description = "Network configurations"
  type = object({
    name         = string
    ipv4_address = string
    ipv6_address = string
    nat          = bool
    dhcp         = bool
    dns_search   = string
    dns_domain   = string
    raw_dnsmasq  = optional(string, "")
  })
  default = {
    name         = "lxdbr0"
    ipv4_address = "172.16.10.1/24"
    ipv6_address = "none"
    nat          = true
    dhcp         = true
    dns_search   = "lxd"
    dns_domain   = "lxd"
    raw_dnsmasq  = <<-EOF
      server=1.1.1.1
    EOF
  }
}

variable "pools" {
  description = "Map of storage pools to create"
  type = map(object({
    pool_source = string
    pool_driver = string
  }))
  default = {}
}

variable "instances" {
  description = "Map of instances to create"
  type = map(object({
    ipv4_address   = string
    cpu            = number
    memory         = string
    root_disk_size = string
    volumes = map(object({
      size = string
      pool = string
    }))
  }))
  default = {}
}
