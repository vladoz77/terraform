data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    server_url         = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint
    ca_certificate     = base64encode(yandex_kubernetes_cluster.k8s-cluster.master[0].cluster_ca_certificate)
    cluster_name       = yandex_kubernetes_cluster.k8s-cluster.name
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${pathexpand("~")}/.kube/config"
}