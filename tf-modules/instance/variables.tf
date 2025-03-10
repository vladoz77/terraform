variable "platform_id" {
  type = string
  description = "yandex instance platform id"
}

variable "zone" {
  type = string
  description = "yandex zone"
}

variable "name" {
  type = string
  description = "vm name"
  nullable = true
}

variable "core_fraction" {
  type = number
  default = 20
}

variable "cores" {
  type = number
  default = 2
  description = "cpu core for vm"
}

variable "memory" {
  type = number
  default = 1
  description = "memory for vm"
}


variable "ssh" {
  type = string
  description = "ssh key for connect to instance"
  nullable = true
}

variable "tags" {
  type = list(string)
  description = "tags for vm"
  nullable = true
}

variable "network_interfaces" {
  type = list(object({
    subnet_id = string
    nat       = bool
    ip_address = optional(string)
    security_group = optional(set(string))
  }))
  description = "List of network interfaces for the VM."
  default = [{
    subnet_id = ""
    nat       = true
    ip_address = null
    security_group = null
  }]
}

variable "boot_disk" {
  type = object({
    disk_image_id = string
    disk_type = string
    disk_size = number
  })
}

variable "labels" {
  type = map(string)
  nullable = true
}
