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

variable "selectel_domain_name" {
  type        = string
  description = "selectel domain name"
}

variable "project_id" {
  type        = string
  description = "project id in selectel"
  sensitive   = true
}

variable "zone_id" {
  type        = string
  default     = "ru-7"
  description = "zone id"
}

variable "access_key" {
  type        = string
  description = "access key for state bucket"
  sensitive = true
}

variable "secret_key" {
  type        = string
  description = "access key for state bucket"
  sensitive = true
}

variable "os_version" {
  default     = "Ubuntu 24.04 LTS 64-bit"
  type        = string
  description = "Os for instance"
}

