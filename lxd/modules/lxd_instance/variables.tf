variable "network_name" {
  description = "Network name for instance"
  type = string
}

variable "attached_volume" {
  description = "Map of existing volumes to attach to the instance"
  type = map(object({
    pool = string
    name = string
    path = optional(string)
  }))
  default = {}
}

variable "instance" {
  description = "Instance config"
  type = object({
    profile = optional(string)
    name    = string
    cpu = number
    memory = string
    ipv4_address = optional(string)
    root_name = string
    image = string
    description = optional(string)
    cloud_init = optional(string, null)
  })
}