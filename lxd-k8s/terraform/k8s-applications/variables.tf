variable "kube_config_path" {
  default     = "~/.kube/config"
  description = "path for kubeconfig"
  type        = string
}


variable "ca_subject" {
  description = "subject field for ca certificate"
  type = object({
    organizations        = list(string)
    organizational_units = list(string)
    localities           = list(string)
    countries            = list(string)
  })
  default = {
    countries            = ["RU"]
    organizational_units = ["Home lab"]
    localities           = ["Ryazan"]
    organizations        = ["Vlad's homelab"]
  }
}

variable "ca_issuer" {
  description = "ca issuer config"
  type = object({
    name        = string
    secret_name = string
  })
  default = {
    name        = "ca-issuer"
    secret_name = "ca-secret"
  }
}