resource "yandex_storage_bucket" "terraform-bucket" {
  bucket                = "terraform"
  default_storage_class = "standard"
  acl = "private"
  
  

  versioning {
    enabled = true
  }
}
