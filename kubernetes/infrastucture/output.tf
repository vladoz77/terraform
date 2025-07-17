output "cluster_id" {
  value = yandex_kubernetes_cluster.k8s-cluster[*].id
}

output "external-ipv4" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[*].external_v4_address
}

output "service-range" {
  value = yandex_kubernetes_cluster.k8s-cluster[*].service_ipv4_range
}

output "ingress-static-ip" {
  value = yandex_vpc_address.lb-static-ip.external_ipv4_address[0].address
}

