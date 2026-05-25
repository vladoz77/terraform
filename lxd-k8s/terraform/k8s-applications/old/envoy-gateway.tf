locals {
  namespace = "envoy-gateway-system"
  gateway_class = "envoy-gateway-class"
}

# Install envoy-controller
resource "helm_release" "envoy_gateway_controller" {
  name         = "envoy-gateway"
  chart            = "gateway-helm"
  repository       = "oci://docker.io/envoyproxy"
  version          = "v1.7.0"
  namespace        = local.namespace
  create_namespace = true
  atomic = true
  cleanup_on_fail = true
}

# Install gatewayclass
resource "kubectl_manifest" "envoy_gatewayclass" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "GatewayClass"
    metadata = {
      name = local.gateway_class
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
    }
  })
  depends_on = [ helm_release.envoy_gateway_controller ]
}

# Install default gateway
resource "kubectl_manifest" "gateway" {
  yaml_body = templatefile("${path.module}/templates/envoy-default-gateway.yaml.tpl", {
    namespace      = local.namespace
    cluster_issuer = var.ca_issuer.name
    wildcard       = "*.home.local"
    cert_secret    = var.ca_issuer.secret_name
    gateway_class  = local.gateway_class
  })
  depends_on = [kubectl_manifest.envoy_gatewayclass]
}

