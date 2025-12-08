variable "role_id" {
  description = "vault role"
  type        = string
  sensitive   = true
}

variable "secret_id" {
  description = "vault secret-id"
  type        = string
  sensitive = true
}

variable "vault_address" {
  description = "vault address"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "zone for yc"
  default     = "ru-central1-a"
  type        = string
}

variable "username" {
  description = "username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_key" {
  description = "ssh-keys for host"
  type        = string
  # export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
}


variable "platform_id" {
  description = "platform id Yandex Cloud"
  type        = string
}


variable "monitoring" {
  description = "monitoring vm config"
  type = object({
    count         = number
    instance_name = string
    cpu           = number
    core_fraction = number
    memory        = number
    boot_disk = object({
      type     = string
      size     = number
      image_id = string
    })
    tags        = optional(list(string))
    environment = optional(map(string))
    dns_records = map(object({
      name = string
      ttl  = number
      type = string
    }))
  })
  default = {
    count         = 1
    instance_name = "monitoring-server"
    cpu           = 1
    core_fraction = 20
    memory        = 2
    tags          = []
    environment   = {}
    boot_disk = {
      type     = "network-hdd"
      size     = 20
      image_id = "fd81hgrcv6lsnkremf32"
    }
    dns_records = {}
  }
}