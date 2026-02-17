resource "helm_release" "cert-manager" {
  name         = "cert-manager"
  chart        = "cert-manager"
  repository   = "https://charts.jetstack.io/"
  namespace    = "cert-manager"
  version      = "1.19.2"
  force_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true

  values = [yamlencode({
    crds = {
      enabled = true
      keep    = false
    }
    config = {
      enableGatewayAPI = true
    }
  })]
  depends_on = [ helm_release.envoy_gateway_controller ]
}

resource "kubectl_manifest" "clusterissuer" {
  depends_on = [helm_release.cert-manager]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  })
}

resource "kubectl_manifest" "root_ca_certificate" {
  depends_on = [kubectl_manifest.clusterissuer]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "ca"
      namespace = "cert-manager"
    }
    spec = {
      isCA       = true
      commonName = "Vlad's Homelab Root CA"   
      subject    = var.ca_subject
      secretName = "ca-secret"
      privateKey = {
        algorithm = "RSA"
        encoding  = "PKCS8"
        size      = 4096
      }
      issuerRef = {
        name  = "selfsigned-issuer"
        group = "cert-manager.io"
        kind  = "ClusterIssuer"
      }
    }
  })
}

resource "kubectl_manifest" "ca_issuer" {
  depends_on = [kubectl_manifest.root_ca_certificate]
  
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "ca-issuer"
    }
    spec = {
      ca = {
        secretName = "ca-secret"
      }
    }
  })
}