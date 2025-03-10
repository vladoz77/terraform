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

variable "username" {
  description = "username"
  type = string
  default = "ubuntu"
}

variable "ssh_key" {
  description = "ssh-keys for host"
  #  export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
}