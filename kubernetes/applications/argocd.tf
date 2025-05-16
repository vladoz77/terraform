resource "helm_release" "argocd" {
  name = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  version = "2.0.2"
  chart = "argocd-apps"
  namespace = "argocd"
  create_namespace = true

  values = [file("${path.module}/argocd/values.yaml")]

}