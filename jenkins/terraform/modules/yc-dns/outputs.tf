output "zone_id" {
  description = "DNS zone ID"
  value       = var.create_zone ? yandex_dns_zone.zone[0].id : null
}

output "zone_name" {
  description = "DNS zone name"
  value       = var.create_zone ? yandex_dns_zone.zone[0].name : null
}