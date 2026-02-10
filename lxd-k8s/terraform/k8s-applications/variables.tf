variable "kube_config_path" {
  default     = "~/.kube/config"
  description = "path for kubeconfig"
  type        = string
}

variable "metallb_ippool" {
  description = "ip address pool for metallb"
  type        = list(string)
  default     = ["192.168.200.250-192.168.200.255"]
}

variable "ca_subject" {
  description = "subject field for ca certificate"
  type = object({
    organizations       = list(string)
    organizationalUnits = list(string)
    localities          = list(string)
    countries           = list(string)
  })
  default = {
    countries           = ["RU"]
    organizationalUnits = ["Home lab"]
    localities          = ["Ryazan"]
    organizations       = ["Vlad's homelab"]
  }
}