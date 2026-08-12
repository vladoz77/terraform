# main.tf
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}

# Install envoy-controller
resource "helm_release" "gateway_controller" {
  name             = var.gateway_controller.name
  chart            = var.gateway_controller.chart_name
  repository       = var.gateway_controller.repository
  version          = var.gateway_controller.version
  namespace        = var.namespace
  create_namespace = var.gateway_controller.create_namespace
  cleanup_on_fail  = var.gateway_controller.cleanup_on_fail
}

locals {
  gateway_class_name = var.gateway_class
  envoy_proxies = {
    for gw_key, gw_val in var.gateway : "${gw_val.address_pool}-proxy" => {
      address_pool = gw_val.address_pool
      namespace    = gw_val.namespace
    } if gw_val.address_pool != null
  }
}

# Install GatewayClass
resource "kubectl_manifest" "envoy_gatewayclass" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = local.gateway_class_name
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
    }
  })
  depends_on = [helm_release.gateway_controller]
}

# Install envoy-proxy
resource "kubectl_manifest" "envoy_proxy" {
  for_each = local.envoy_proxies
  yaml_body = yamlencode({
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "EnvoyProxy"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
    }
    spec = {
      provider = {
        type = "Kubernetes"
        kubernetes = {
          envoyService = {
            annotations = {
              "metallb.universe.tf/address-pool" = each.value.address_pool
            }
          }
        }
      }
    }
  })
  depends_on = [helm_release.gateway_controller]
}

# Install default gateway
resource "kubectl_manifest" "gateway" {
  for_each   = var.gateway
  depends_on = [kubectl_manifest.envoy_gatewayclass, kubectl_manifest.envoy_proxy]
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
      annotations = anytrue([for l in each.value.listeners : l.protocol == "HTTPS"]) ? {
        "cert-manager.io/cluster-issuer" = each.value.cluster_issuer
      } : null
    }
    spec = {
      gatewayClassName = local.gateway_class_name
      infrastructure = {
        parametersRef = {
          group = "gateway.envoyproxy.io"
          kind  = "EnvoyProxy"
          name  = "${each.value.address_pool}-proxy"
        }
      }
      listeners = [
        for l in each.value.listeners : {
          name      = l.name
          port      = l.port
          protocol  = l.protocol
          hostnames = length(l.hostnames) > 0 ? l.hostnames : null
          allowedRoutes = l.allowed_routes != null ? {
            namespaces = {
              from = l.allowed_routes.namespaces_from
            }
          } : null
          tls = l.protocol == "HTTPS" ? {
            mode = "Terminate"
            certificateRefs = [{
              kind = "Secret"
              name = "${each.key}-tls-secret"
            }]
          } : null
        }
      ]
    }
  })
}
