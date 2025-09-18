output "network_id" {
  value = module.network.network_id
}

output "subnet_id" {
  value = module.network.subnet_id
}


output "network_cidr" {
  value = module.network.network_cidr
}

output "zone_id" {
  value = yandex_dns_zone.zone.id
}
