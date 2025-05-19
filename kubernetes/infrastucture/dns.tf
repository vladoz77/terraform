resource "yandex_dns_recordset" "argocd_record" {
  zone_id = data.terraform_remote_state.network.outputs.zone_id
  name = "argocd"
  type = "A"
  ttl = 300
  data = [yandex_vpc_address.lb-static-ip.external_ipv4_address[0].address]
}