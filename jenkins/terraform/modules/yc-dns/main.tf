terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"
}

resource "yandex_dns_zone" "zone" {
  count = var.create_zone ? 1 : 0

  name        = var.dns_zone.name
  description = var.dns_zone.description
  zone        = var.dns_zone.zone
  public      = var.dns_zone.public
  private_networks = [var.private_networks]
  deletion_protection = var.dns_zone.deletion_protection
}

locals {
  final_zone_id = var.create_zone ? yandex_dns_zone.zone[0].id : var.zone_id
}

resource "yandex_dns_recordset" "records" {
  for_each = var.dns_records

  zone_id = local.final_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  data    = each.value.data
}