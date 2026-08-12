module "metallb" {
  source = "./modules/metallb"
  
  name             = "metallb"
  namespace        = "metallb-system"
  chart_version    = "0.15.3"
  create_namespace = true
  ippools          = {
    "system-pool" = ["172.18.255.200-172.18.255.250"]
    "production-pool" = ["10.0.1.0/24"]
  }
}

module "gateway" {
  source = "./modules/gateway"
  namespace = "envoy-gateway-system"
  gateway_class = "envoy-gateway-class"
  gateway_controller = {
    name = "envoy-gateway"
    chart_name = "gateway-helm"
    version = "v1.7.0"
    repository = "oci://docker.io/envoyproxy"
    create_namespace = true
    cleanup_on_fail = true
  }
  gateway = {
    "system-gateway" = {
      class_name     = "envoy-gateway-class"
      namespace      = "envoy-gateway-system"
      address_pool = "system-pool"
      listeners = [
        {
          name      = "http"
          port      = 80
          protocol  = "HTTP"
          hostnames = ["*.dev.local"]
          allowed_routes = {
            namespaces_from = "All"
          }
        }
      ]
    },
    "production-gateway" = {
      class_name     = "envoy-gateway-class"
      namespace      = "default"
      address_pool = "production-pool"
      listeners = [
        {
          name      = "http"
          port      = 80
          protocol  = "HTTP"
          hostnames = ["*.home.com"]
          allowed_routes = {
            namespaces_from = "All"
          }
        }
      ]
    }
  }
}

output "ippools_name" {
  value = {for pool in module.metallb.ippools : pool.name => pool.addresses}
  
}

output "gateway" {
  value = {for key, value in module.gateway.gateway_info : key => value.namespace
  
  }
}