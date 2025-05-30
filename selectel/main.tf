module "cloudinit" {
  source = "./modules/cloudinit_devops_factory"

  username   = var.selectel_username
  password   = var.selectel_password
  account_id = local.selectel_domain_name
}