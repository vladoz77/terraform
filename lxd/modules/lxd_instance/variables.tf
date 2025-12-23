variable "lxd_profile_name" {
  default = "instance_profile"
  type = string
  description = "LXD profile name to be used for the instance"
}

variable "network_name" {
  type = string
}

variable "default_storage_pool" {
  type = string
  default = ""
  description = "Storage pool by defaults"
}

variable "instance" {
  type = object({
    name         = string
    image        = string
    type         = string
    ipv4_address = string
    cpu          = number
    memory       = string
    cloud_init   = string
    root_pool_name    = string
    root_disk_size = string
  })
}

variable "additional_volumes" {
  type = map(object({
    size = string
    pool = string
  }))
  default = {}
}

variable "wait_timeout" {
  description = "Timeout in seconds to wait for instance to become available via SSH"
  type        = number
  default     = 300
}