variable "selectel_username" {
  type        = string
  sensitive   = true
  description = "username for selectel account"
}

variable "selectel_password" {
  type        = string
  sensitive   = true
  description = "selectel account password"
}


variable "zone_id" {
  type        = string
  default     = "ru-7"
  description = "zone id"
}

variable "disk_type" {
  default     = "basic.ru-7a"
  description = "disk type"
  type        = string
}
