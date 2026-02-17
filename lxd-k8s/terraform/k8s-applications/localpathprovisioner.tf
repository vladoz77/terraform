resource "kubectl_manifest" "local_path_provisioner" {
  yaml_body        = file("${path.module}/files/local-path-provisioner.yaml")
  wait_for_rollout = true
}