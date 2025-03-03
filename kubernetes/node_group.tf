resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = local.k8s_node_group_name
  description = "worker node"
  version     = "1.30"
  

  scale_policy {
    fixed_scale {
      size = local.k8s_node_group_count
    }
  }
  
  instance_template {
    platform_id = local.k8s_node_group_platform_id
    resources {
      cores         = local.k8s_node_group_cpu
      core_fraction = 50
      memory        = local.k8s_node_group_memory
    }

    container_runtime {
      type = "containerd"
    }

    boot_disk {
      size = 64
      type = "network-hdd"
    }
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      security_group_ids = [
        yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
        yandex_vpc_security_group.k8s-nodegroup-traffic.id,
        yandex_vpc_security_group.k8s-services-access.id,
        yandex_vpc_security_group.k8s-ssh-access.id
      ]
    }
    scheduling_policy {
      preemptible = true
    }
  }
}