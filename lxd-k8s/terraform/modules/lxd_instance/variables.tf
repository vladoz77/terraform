variable "network_name" {
  type = string
}

variable "storage_pool" {
  type = string
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
    root_pool    = string
    root_pool_size = string
  })
}

variable "volumes" {
  type = map(object({
    size = string
  }))
  default = {}
}