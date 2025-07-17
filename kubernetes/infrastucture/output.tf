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

output "ca_certificate" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[*].cluster_ca_certificate
}

output "external_v4_endpoint" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[*].external_v4_endpoint
}