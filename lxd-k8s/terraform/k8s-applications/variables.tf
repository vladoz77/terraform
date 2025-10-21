variable "kube_config_path" {
  default     = "~/.kube/config"
  description = "path for kubeconfig"
  type        = string
}

variable "metallb_ippool" {
  description = "ip address pool for metallb"
}