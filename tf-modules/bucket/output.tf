output "bucket_name" {
  value = yandex_storage_bucket.s3.id
}

output "site_address" {
  value = yandex_storage_bucket.s3.website_endpoint
}
