resource "null_resource" "generate_kubeconfig" {
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.k8s-cluster.id} --external --kubeconfig $HOME/.kube/config --force"
  }

  depends_on = [yandex_kubernetes_cluster.k8s-cluster]
}