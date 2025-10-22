resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.12"
  namespace  = "metallb-system"

  create_namespace = true
}

resource "kubectl_manifest" "ippool" {
  depends_on = [helm_release.metallb]
  yaml_body  = <<YAML
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: first-pool
      namespace: metallb-system
    spec:
      addresses:
      - 192.168.200.250-192.168.200.255
  YAML
}

resource "kubectl_manifest" "l2advertisements" {
  depends_on = [helm_release.metallb]
  yaml_body  = <<YAML
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: first-pool
      namespace: metallb-system
  YAML
}