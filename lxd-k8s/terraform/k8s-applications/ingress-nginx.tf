resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.2"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("${path.module}/files/ingress-nginx.yaml")]

  depends_on = [helm_release.cert-manager]

}
