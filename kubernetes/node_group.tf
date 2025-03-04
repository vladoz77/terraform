resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = local.k8s_node_group_name
  description = "worker node"
  version     = local.k8s_version
  

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
      size = local.k8s_node_boot_disk_size
      type = local.k8s_node_boot_disk_type
    }
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      security_group_ids = local.k8s_node_security_group_ids
    }
    scheduling_policy {
      preemptible = true
    }
  }
}