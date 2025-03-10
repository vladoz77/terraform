# Terraform Module: Yandex Storage Bucket

This module creates a Yandex Storage Bucket with support for versioning, lifecycle rules and encryption.

## Usage

```hcl
module "bucket" {
  source = ""github.com/devopsfabric/cloud_sprint_vladoz77//tf-modules/bucket?ref=v1.0""

  bucket_name       = "my-bucket"
  acl               = "private"
  versioning_enable = true
  index             = "index.html"
  rules = [
    {
      id      = "rule1"
      enabled = true
      days    = 30
      prefix  = "logs/"
    }
  ]
}