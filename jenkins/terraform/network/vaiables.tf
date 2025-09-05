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

variable "network" {
  description = "Network config"
  type = object({
    network_name = string
    subnet_name = string
    ipv4_cidr  = string
    })
}

variable "dns_zone" {
  description = "config dns zone"
  type = object({
    name = string
    description = optional(string)
    zone = string
    public = bool
    deletion_protection = optional(bool, true)
  })
  default     = null
  nullable    = true
}

variable "dns_records" {
  description = "dns records"
  type = map(object({
    name = string
    type = string
    ttl  = number
    data = list(string)
  }))
  default     = null
  nullable    = true
}