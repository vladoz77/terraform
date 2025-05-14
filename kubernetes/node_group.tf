resource "yandex_kubernetes_node_group" "k8s-node-group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = local.node_group.group_name
  description = "worker node"
  version     = var.k8s_version
  
  
  

  scale_policy {
    fixed_scale {
      size = local.node_group.scale
    }
  }
  
  instance_template {
    platform_id = local.node_group.platform_id
    resources {
      cores         = local.node_group.cpu
      core_fraction = 50
      memory        = local.node_group.memory
    }

    container_runtime {
      type = "containerd"
    }

    boot_disk {
      size = local.node_group.disk_size
      type = local.node_group.disk_type
    }
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.k8s_subnet.id]
      # security_group_ids = local.node_group.security_group_ids
    }
    scheduling_policy {
      preemptible = true
    }

    metadata = {
      ssh-keys = local.node_group.ssh
    }
  }

  
}