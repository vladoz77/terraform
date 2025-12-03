resource "null_resource" "longhorn_annotate_worker" {
  for_each = local.k8s_worker_node_names
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<-EOT
        kubectl annotate node "${each.value}" \
        node.longhorn.io/default-disks-config='[{"name":"data","path":"/mnt/data","allowScheduling":true,"tags":["hdd"]}]' \
        --overwrite
    EOT
  }
}