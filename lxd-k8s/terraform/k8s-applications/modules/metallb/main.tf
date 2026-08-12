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


resource "helm_release" "metallb" {
  name       = var.name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = var.create_namespace
  force_update     = true
}

resource "kubectl_manifest" "ippool" {
  depends_on = [helm_release.metallb]
  for_each = var.ippools
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = each.key
      namespace = var.namespace
    }
    spec = {
      addresses = each.value
    }
  })
}

resource "kubectl_manifest" "l2advertisements" {
  for_each = var.ippools
  depends_on = [kubectl_manifest.ippool]
  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = each.key
      namespace = var.namespace
    }
    spec = {
      ipAddressPools = [each.key]
    }
  })
}