resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.12"
  namespace  = "metallb-system"

  create_namespace = true
  force_update     = true
}

resource "kubectl_manifest" "ippool" {
  depends_on = [helm_release.metallb]
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "first-pool"
      namespace = "metallb-system"
    }
    spec = {
      addresses = var.metallb_ippool
    }
  })
}

resource "kubectl_manifest" "l2advertisements" {
  depends_on = [helm_release.metallb]
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "first-pool"
      namespace = "metallb-system"
    }
  })
}