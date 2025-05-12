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

variable "additional_disks" {
  nullable = true
  type = list(object({
    size = number
    type = string  # Тип диска (network-hdd, network-ssd, network-ssd-nonreplicated)
  }))
  description = "add additional disk for vm"
  default = [ {
    size = null
    type = null
  } ]
}

variable "labels" {
  type = map(string)
  nullable = true
}

variable "env_vars" {
  type = map(string)
  default = {
    DB = "db.test.local"
  }
  description = "Env vars to inject to instance"
  nullable = true
}

variable "username" {
  type = string
  default = "ubuntu"
  description = "default user for vm"
}

variable "cloud_init" {
  description = "YAML content for cloud-init configuration"
  type        = string
  default     = null
  sensitive   = false
  nullable = true
}