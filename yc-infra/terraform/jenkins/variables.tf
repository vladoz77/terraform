# Vault Role ID для аутентификации в Hashicorp Vault
variable "role_id" {
  description = "vault role"
  type        = string
}

# Vault Secret ID для аутентификации в Hashicorp Vault
variable "secret_id" {
  description = "vault secret-id"
  type        = string
}

# Зона доступности Yandex Cloud
variable "zone" {
  description = "zone for yc"
  default     = "ru-central1-a"
  type        = string
}

# Имя пользователя для SSH доступа
variable "username" {
  description = "username"
  type        = string
  default     = "ubuntu"
}

# Публичный SSH-ключ для доступа к виртуальным машинам
variable "ssh_key" {
  description = "ssh-keys for host"
  type        = string
  # export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
}


variable "platform_id" {
  description = "platform id Yandex Cloud"
  type        = string
}

variable "jenkins_dns_records" {
  description = "dns records for yc"
  type        = string
  default     = ""
}


variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}


variable "jenkins" {
  description = "jenkins vm config"
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
  })
  default = {
    count         = 1
    instance_name = "jenkins-server"
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
  }
}

variable "jenkins-agent" {
  description = "jenkins-agent vm config"
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
  })
  default = {
    count         = 1
    instance_name = "jenkins-agent"
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
  }
}


