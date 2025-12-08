variable "environment" {
  type = string
  description = "Type of environment"
}

variable "lxd_profile_name" {
  default = "instance"
  type = string
}

variable "lxd_image_os" {
  default = ""
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
