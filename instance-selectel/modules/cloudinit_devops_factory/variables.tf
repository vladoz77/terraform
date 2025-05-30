variable "username" {
  description = "username of service account running terraform"
  type        = string
}

variable "password" {
  description = "password of service account running terraform"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "domain (account number)"
  type        = string
}

