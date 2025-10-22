variable "kube_config_path" {
  default     = "~/.kube/config"
  description = "path for kubeconfig"
  type        = string
}

variable "metallb_ippool" {
  description = "ip address pool for metallb"
  type        = string
  default     = "192.168.200.250-192.168.200.255"
}