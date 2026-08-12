variable "kube_config_path" {
  default     = "~/.kube/config"
  description = "path for kubeconfig"
  type        = string
}

variable "name" {
  description = "name for metallb release"
  type        = string
  default     = "metallb"
}

variable "namespace" {
  description = "namespace for metallb release"
  type        = string
  default     = "metallb-system"
}

variable "chart_version" {
  description = "version for metallb release"
  type        = string
  default     = "0.16.0"
}

variable "create_namespace" {
  description = "whether to create namespace for metallb release"
  type        = bool
  default     = true
}

variable "ippools" {
  description = "IP address pools for metallb"
  type        = map(list(string)) 
  default     = {
    "default-pool" = ["10.0.0.0/24"]
  }
}