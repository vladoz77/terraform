variable "namespace" {
  description = "envoy gateway helm chart name"
  type        = string
  default     = "envoy-gateway-system"
}

variable "gateway_class" {
  description = "envoy gateway class name"
  type        = string
  default     = "envoy-gateway-class"
}

variable "gateway_controller" {
  description = "envoy gateway helm release config"
  type = object({
    name             = string
    chart_name       = string
    version          = string
    repository       = string
    create_namespace = bool
    cleanup_on_fail  = bool
  })
  default = {
    name             = "envoy-gateway"
    chart_name       = "gateway-helm"
    version          = "v1.7.0"
    repository       = "oci://docker.io/envoyproxy"
    create_namespace = true
    cleanup_on_fail  = true
  }
}

variable "gateway" {
  type = map(object({
    class_name     = string
    namespace      = string
    cluster_issuer = optional(string, null)
    address_pool   = optional(string, null)
    listeners = list(object({
      name      = string
      port      = number
      protocol  = string
      hostnames = optional(list(string), [])
      allowed_routes = optional(object({
        namespaces_from = optional(string, "All")
      }), null)
    }))
  }))

  default = {
    "example-gateway" = {
      class_name     = "envoy-gateway-class"
      namespace      = "envoy-gateway-system"
      cluster_issuer = "letsencrypt-prod"
      listeners = [
        {
          name      = "http"
          port      = 80
          protocol  = "HTTP"
          hostnames = ["example.com"]
          allowed_routes = {
            namespaces_from = "All"
          }
        },
        {
          name      = "https"
          port      = 443
          protocol  = "HTTPS"
          hostnames = ["example.com"]
        }
      ]
    }
  }
}
