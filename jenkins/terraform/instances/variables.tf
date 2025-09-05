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
  type = string
  # export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
}

variable "image_id" {
  description = "OS images for instance"
  type = string
}

variable "disk_type" {
  description = "type of disk"
  type = string
  default = "network-hdd"
}

variable "platform_id" {
  description = "platform id Yandex Cloud"
  type = string
}


variable "jenkins" {
  description = "jenkins vm config"
  type = object({
    count = number
    instance_name = string
    cpu = number
    core_fraction = number
    memory = number
    disk_size = number
    tags = optional(list(string))
    environment = optional(map(string))
  })
  default = {
    count = 1
    instance_name = "jenkins-server"
    cpu = 1
    core_fraction = 20
    memory = 2
    disk_size = 20
    tags = []
    environment = {}
  }
}

variable "jenkins-agent" {
  description = "jenkins-agent vm config"
  type = object({
    count = number
    instance_name = string
    cpu = number
    core_fraction = number
    memory = number
    disk_size = number
    tags = optional(list(string))
    environment = optional(map(string))
  })
  default = {
    count = 1
    instance_name = "jenkins-agent"
    cpu = 1
    core_fraction = 20
    memory = 2
    disk_size = 20
    tags = []
    environment = {}     
  }
}


