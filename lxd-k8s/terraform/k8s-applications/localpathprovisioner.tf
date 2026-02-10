# ServiceAccount
resource "kubernetes_service_account_v1" "local_path_provisioner" {
  metadata {
    name      = "local-path-provisioner-service-account"
    namespace = "kube-system"
  }
}

# Role (namespaced)
resource "kubernetes_role_v1" "local_path_provisioner" {
  metadata {
    name      = "local-path-provisioner-role"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "create", "patch", "update", "delete"]
  }
}

# ClusterRole
resource "kubernetes_cluster_role_v1" "local_path_provisioner" {
  metadata {
    name = "local-path-provisioner-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "persistentvolumeclaims", "configmaps", "pods", "pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "patch", "update", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
}

# RoleBinding
resource "kubernetes_role_binding_v1" "local_path_provisioner" {
  metadata {
    name      = "local-path-provisioner-bind"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.local_path_provisioner.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.local_path_provisioner.metadata[0].name
    namespace = "kube-system"
  }
}

# ClusterRoleBinding
resource "kubernetes_cluster_role_binding_v1" "local_path_provisioner" {
  metadata {
    name = "local-path-provisioner-bind"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.local_path_provisioner.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.local_path_provisioner.metadata[0].name
    namespace = "kube-system"
  }
}

# ConfigMap
resource "kubernetes_config_map_v1" "local_path_config" {
  metadata {
    name      = "local-path-config"
    namespace = "kube-system"
  }

  data = {
    "config.json"    = file("${path.module}/files/localpathprovsioner/config.json")
    "setup"          = file("${path.module}/files/localpathprovsioner/setup.sh")
    "teardown"       = file("${path.module}/files/localpathprovsioner/teardown.sh")
    "helperPod.yaml" = file("${path.module}/files/localpathprovsioner/helperpod.yaml")
  }
}

# Deployment
resource "kubernetes_deployment_v1" "local_path_provisioner" {
  depends_on = [
    kubernetes_config_map_v1.local_path_config,
    kubernetes_service_account_v1.local_path_provisioner
  ]

  metadata {
    name      = "local-path-provisioner"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-path-provisioner"
      }
    }

    template {
      metadata {
        labels = {
          app = "local-path-provisioner"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.local_path_provisioner.metadata[0].name

        container {
          name              = "local-path-provisioner"
          image             = "rancher/local-path-provisioner:master-head"
          image_pull_policy = "IfNotPresent"

          command = [
            "local-path-provisioner",
            "--debug",
            "start",
            "--config",
            "/etc/config/config.json"
          ]

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config/"
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "CONFIG_MOUNT_PATH"
            value = "/etc/config/"
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map_v1.local_path_config.metadata[0].name
          }
        }
      }
    }
  }
}

# StorageClass
resource "kubernetes_storage_class_v1" "local_path" {
  metadata {
    name = "local-path"
  }

  storage_provisioner = "rancher.io/local-path"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"

  depends_on = [kubernetes_deployment_v1.local_path_provisioner]
}