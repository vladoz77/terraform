variable "cloud_id" {
  type = string
  description = "yandex cloud_id"
}

variable "folder_id" {
  type = string
  description = "yandex folder_id"
}

variable "token" {
  description = "yandex cloud token"
}

variable "zone" {
  description = "zone for yc"
  default     = "ru-central1-a"
  type        = string
}
