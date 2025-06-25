# Получаем outputs из common_instances
data "terraform_remote_state" "common_instances" {
  backend = "s3"
  config = {
    bucket = "plane-state-bucket"
    key    = "common/terraform.tfstate"
    region = "ru-7"

    endpoints = {
      s3 = "https://s3.ru-7.storage.selcloud.ru"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# Получаем outputs из dev-instances
data "terraform_remote_state" "dev-instances" {
  backend = "s3"
  config = {
    bucket = "plane-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "ru-7"

    endpoints = {
      s3 = "https://s3.ru-7.storage.selcloud.ru"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# Получаем outputs из prod-instances
data "terraform_remote_state" "prod-instances" {
  backend = "s3"
  config = {
    bucket = "plane-state-bucket"
    key    = "prod/terraform.tfstate"
    region = "ru-7"

    endpoints = {
      s3 = "https://s3.ru-7.storage.selcloud.ru"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

resource "local_file" "inventory" {
  content = templatefile("./inventory.tfpl", {
    monitoring   = flatten(data.terraform_remote_state.common_instances.outputs.monitoring_public_ip)
    runner       = flatten(data.terraform_remote_state.common_instances.outputs.runner_public_ip)
    plane_prod   = flatten(data.terraform_remote_state.prod-instances.outputs.plane_public_ip)
    backend_prod = flatten(data.terraform_remote_state.prod-instances.outputs.backend_public_ip)
    plane_dev    = flatten(data.terraform_remote_state.dev-instances.outputs.plane_public_ip)
    backend_dev  = flatten(data.terraform_remote_state.dev-instances.outputs.backend_public_ip)
  })
  filename = "../../ansible/inventories/inventory.ini"
}