
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name = var.cluster_name

  network_id = data.terraform_remote_state.network.outputs.network_id

  master {
    version = var.k8s_version
    master_location {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }

    public_ip = true

    # security_group_ids = local.cluster.security_group_ids

    maintenance_policy {
      auto_upgrade = true
    }

    master_logging {
      enabled                    = true
      folder_id                  = var.folder_id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }
  }

  release_channel = "STABLE"

  cluster_ipv4_range = local.cluster.ipv4_range
  service_ipv4_range = local.cluster.service_ipv4_range

  service_account_id      = yandex_iam_service_account.sa-k8s-admin.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-admin.id
  depends_on              = [yandex_resourcemanager_folder_iam_member.sa-k8s-admin-permissions]
}