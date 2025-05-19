resource "helm_release" "argocd" {
  name = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  version = "8.0.0"
  chart = "argo-cd"
  namespace = "argocd"
  create_namespace = true

  values = [file("${path.module}/argocd/values.yaml")]
  depends_on = [ helm_release.cert-manager, helm_release.ingress-nginx ]
}