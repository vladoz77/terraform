variable "private_networks" {
  description = "network_id to connect"
  type = string
  default = null
  nullable = true
}

variable "create_zone" {
  type        = bool
  description = "Whether to create DNS zone"
  default     = true
}

variable "zone_id" {
  type        = string
  description = "DNS zone ID (optional if creating zone)"
  default     = null
}

variable "dns_zone" {
  description = "DNS zone configuration"
  type = object({
    name               = string
    description        = optional(string, "")
    zone               = string
    public             = optional(bool, true)
    deletion_protection = optional(bool, true)
  })
  default = null
  
}

variable "dns_records" {
  description = "DNS records"
  type = map(object({
    name = string
    type = string
    ttl  = number
    data = list(string)
  }))
  default = {}
}