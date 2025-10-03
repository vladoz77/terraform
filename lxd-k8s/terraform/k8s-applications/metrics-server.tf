resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.13.0"

  values = [
    <<-EOT
    nameOverride: metrics-server
    fullnameOverride: metrics-server
    args:
      - --kubelet-insecure-tls
      - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    EOT
  ]
}