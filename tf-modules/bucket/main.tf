terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"
}

resource "yandex_storage_bucket" "s3" {
  bucket = var.bucket_name
  acl    = var.acl 
  tags   = var.tags

  website {
    index_document = var.index
    error_document = var.index
  }

  versioning {
    enabled = var.versioning_enable
  }


  dynamic "lifecycle_rule" {
    for_each = var.rules
    content {
      id = lifecycle_rule.value.id
      enabled = lifecycle_rule.value.enabled
      expiration {
        days = lifecycle_rule.value.days
      }
      filter {
        prefix = lifecycle_rule.value.prefix
      }
    }
  }
}