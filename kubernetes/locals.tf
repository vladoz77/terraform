locals {
  sa_name = "sa-k8s-admin"
  network_name = "k8s_network"
  subnet_name = "k8s_subnet"
  v4_cidr_blocks = "172.16.10.0/24"

  k8s_cluster_name = "k8s-cluster"
  k8s_version = "1.30"
  k8s_cluster_ipv4_range = "10.244.0.0/16"
  k8s_service_ipv4_range = "10.243.0.0/16"
  k8s_cluster_security_group_ids = [
    yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
    yandex_vpc_security_group.k8s-cluster-traffic.id
  ]

  k8s_node_group_name = "k8s-worker"
  k8s_node_group_platform_id = "standard-v2"
  k8s_node_group_cpu = 2
  k8s_node_group_memory = 4
  k8s_node_boot_disk_type = "network-hdd"
  k8s_node_boot_disk_size = 64
  k8s_node_group_count = 1
  k8s_node_security_group_ids = [
    yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
    yandex_vpc_security_group.k8s-nodegroup-traffic.id,
    yandex_vpc_security_group.k8s-services-access.id,
    yandex_vpc_security_group.k8s-ssh-access.id
  ]
}