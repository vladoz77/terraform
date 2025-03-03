variable "role_id" {
  description = "vault role"
  type        = string
}

variable "secret_id" {
  description = "vault secret-id"
  type        = string
}

variable "zone" {
  description = "zone for yc"
  default     = "ru-central1-a"
  type        = string
}



