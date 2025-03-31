locals {
  cloud_init = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", 
  {
    env_vars = var.env_vars
  }
  )
}