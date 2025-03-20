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

variable "cluster_name" {
  type = string
  default = "yandex-k8s"
}

variable "k8s_version" {
  type = string
  default = "1.30"
}

variable "sa-name" {
  type = string
  default = "sa-k8s-admin"
}

variable "username" {
  description = "username"
  type = string
  default = "ubuntu"
}

variable "ssh_key" {
  type = string
  description = "ssh-keys for host"  
  # export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
}

variable "roles" {
  type = set(string)
  description = "list roles for sa-account"
  default = [ "k8s.admin", "vpc.publicAdmin", "k8s.clusters.agent", "logging.writer"]
}