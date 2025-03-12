locals {
  network = {
    network_name = "k8s_network"
    subnet_name = "k8s_subnet"
    v4_cidr_blocks = "172.16.10.0/24"
  }
  
  cluster = {
    ipv4_range = "10.244.0.0/16"
    service_ipv4_range = "10.243.0.0/16"
    security_group_ids = [
      yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
      yandex_vpc_security_group.k8s-cluster-traffic.id
    ]
  }

  node_group = {
    group_name = "k8s-worker"
    platform_id = "standard-v2"
    cpu = 2
    memory = 4
    disk_type = "network-hdd"
    disk_size = 64
    scale = 3
    ssh = "${var.username}:${var.ssh_key}"
    security_group_ids = [
      yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
      yandex_vpc_security_group.k8s-nodegroup-traffic.id,
      yandex_vpc_security_group.k8s-services-access.id,
      yandex_vpc_security_group.k8s-ssh-access.id,
      yandex_vpc_security_group.k8s-cluster-traffic.id
    ]
  }
}