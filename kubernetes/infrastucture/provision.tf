# resource "null_resource" "generate_kubeconfig" {
#   provisioner "local-exec" {
#     command = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.k8s-cluster.id} --external --kubeconfig $HOME/.kube/config --force"
#   }

#   depends_on = [yandex_kubernetes_cluster.k8s-cluster]
# }

data "yandex_kubernetes_cluster" "k8s-cluster" {
  name = yandex_kubernetes_cluster.k8s-cluster.name
}

data "yandex_iam_token" "sa-token" {
  service_account_id = yandex_iam_service_account.sa-k8s-admin.id
}

resource "local_file" "kubeconfig" {
  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name = yandex_kubernetes_cluster.k8s-cluster.name
    endpoint = output.external_v4_endpoint
    ca_certificate = output.ca_certificate
    user_name = "sa-k8s-admin"
    user_token = data.yandex_iam_service_account.sa-token.token
  })

  filename = "${path.module}/kubeconfig.yaml"
}