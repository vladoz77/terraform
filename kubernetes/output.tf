output "k8s_version" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[*].version
}

output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.k8s-cluster[*].id
}

output "external-ipv4" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[*].external_v4_address
}

output "service-range" {
  value = yandex_kubernetes_cluster.k8s-cluster[*].service_ipv4_range
}
