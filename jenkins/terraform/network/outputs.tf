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
  value = module.dns.zone_id
}

output "zone_name" {
  value = module.dns.zone_name
}