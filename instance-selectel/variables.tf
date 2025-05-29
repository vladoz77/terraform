variable "selectel_username" {
  type = string
  sensitive = true
  description = "username for selectel account"
}

variable "selectel_password" {
  type = string
  sensitive = true
  description = "selectel account password"
}

variable "selectel_domain_name" {
  type = string
  sensitive = true
  description = "domain name for selectel"
}

variable "zone_id" {
  type = string
  default = "ru-7"
  description = "zone id"
}

variable "project_id" {
  type = string
  sensitive = true
  description = "project id in selectel"
}

variable "disk_type" {
  default = "basic.ru-9a"
  description = "disk type"
  type = string
}
