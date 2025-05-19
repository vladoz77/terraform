resource "yandex_dns_recordset" "argocd_record" {
  zone_id = data.terraform_remote_state.network.outputs.zone_id
  name = "argocd"
  type = "A"
  ttl = 300
  data = [data.terraform_remote_state.k8s_cluster.outputs.ingress-static-ip]
}

resource "yandex_dns_recordset" "plane_record" {
  zone_id = data.terraform_remote_state.network.outputs.zone_id
  name = "plane"
  type = "A"
  ttl = 300
  data = [data.terraform_remote_state.k8s_cluster.outputs.ingress-static-ip]
}