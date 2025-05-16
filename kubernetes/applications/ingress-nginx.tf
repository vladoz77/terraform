resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "4.12.0"
  namespace = "ingress-nginx"
  create_namespace = true

  values = [
    templatefile("${path.module}/ingress-nginx/values.yaml.tpl",{
      loadbalancer-ip = data.terraform_remote_state.k8s_cluster.outputs.ingress-static-ip
    })
  ]
}
