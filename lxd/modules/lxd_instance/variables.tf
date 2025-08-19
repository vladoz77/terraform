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
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance.name))
    error_message = "Имя инстанса должно содержать только латинские буквы, цифры и дефисы."
  }
  validation {
    condition     = var.instance.cpu > 0
    error_message = "Количество CPU должно быть больше 0."
  }
}