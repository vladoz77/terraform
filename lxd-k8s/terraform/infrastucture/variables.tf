variable "lxd_profile_name" {
  default = "instance"
  type = string
}

variable "pools" {
  type = map(object({
    pool_source = string
    pool_driver = string
  }))
}

variable "instances" {
  type = map(object({
    image          = string
    type           = string
    ipv4_address   = string
    cpu            = number
    memory         = string
    root_disk_size = string
    volumes = map(object({
      size = string
      pool = string
    }))
  }))
}
