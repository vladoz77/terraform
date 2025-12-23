variable "lxd_profile_name" {
  type = string
  description = "LXD profile name to be used for the instance"
  default = "instance_profile"
}              
  
variable "network" {
  type = object({
    name         = string
    ipv4_address = string
  })
  description = "Network configuration for the LXD instance"
  default = {
    name         = "lxdbr1"
    ipv4_address = "172.16.10.1/24"
  }
}

variable "instance" {
  description = "LXD instance configuration"
  type = object({
    name           = string
    image          = string
    type           = string
    ipv4_address   = string
    cpu            = number
    memory         = string
    root_disk_size = string
  })
}

