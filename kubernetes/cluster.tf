
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name = local.k8s_cluster_name

  network_id = yandex_vpc_network.network.id

  master {
    version = local.k8s_version
    master_location {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.subnet.id
    }

    public_ip = true

    security_group_ids = [ 
      yandex_vpc_security_group.k8s-cluster-nodegroup-traffic.id,
      yandex_vpc_security_group.k8s-cluster-traffic.id
     ]
    
    maintenance_policy {
      auto_upgrade = true
    }

    master_logging {
      enabled = true
      folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
      kube_apiserver_enabled = true
      cluster_autoscaler_enabled = true
      events_enabled = true
      audit_enabled = true
    }
  }
  
  release_channel = "STABLE"
  
  cluster_ipv4_range = local.k8s_cluster_ipv4_range
  service_ipv4_range = local.k8s_service_ipv4_range

  service_account_id      = yandex_iam_service_account.sa-k8s-admin.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-admin.id
  depends_on              = [yandex_resourcemanager_folder_iam_member.sa-k8s-admin-permissions]
}