
data "openstack_images_image_v2" "os_image" {
  name        = var.os_version
  most_recent = true
  visibility  = "public"
}

data "openstack_networking_network_v2" "network" {
  name = "network"
}

module "cloudinit" {
  source = "../modules/cloudinit_devops_factory"

  username   = var.selectel_username
  password   = var.selectel_password
  account_id = var.selectel_domain_name
}

module "runner" {
  source = "../modules/instance"
  count = local.common_instances.runner.enable ? (length(local.common_instances.runner.ip_addresses) > 0 ? length(local.common_instances.runner.ip_addresses) : local.common_instances.runner.count) : 0 

  instance_name = "runner-${count.index}"
  disk_size = local.common_instances.runner.disk_size
  disk_type = "basic.ru-7a"
  os_image_id = data.openstack_images_image_v2.os_image.id
  vcpu = local.common_instances.runner.vcpu
  memory = local.common_instances.runner.memory
  network_id = data.terraform_remote_state.network.outputs.network_id
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
  zone_id = var.zone_id
  cloud_init = module.cloudinit.cloudinit
  ip_address = length(local.common_instances.runner.ip_addresses) > 0 ? element(local.common_instances.runner.ip_addresses, count.index) : null
}

module "monitoring" {
  source = "../modules/instance"
  count = local.common_instances.monitoring.enable ? (length(local.common_instances.monitoring.ip_addresses) > 0 ? length(local.common_instances.monitoring.ip_addresses) : local.common_instances.monitoring.count) : 0 

  instance_name = "monitoring-${count.index}"
  disk_size = local.common_instances.monitoring.disk_size
  disk_type = "basic.ru-7a"
  os_image_id = data.openstack_images_image_v2.os_image.id
  vcpu = local.common_instances.monitoring.vcpu
  memory = local.common_instances.monitoring.memory
  network_id = data.terraform_remote_state.network.outputs.network_id
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
  zone_id = var.zone_id
  cloud_init = module.cloudinit.cloudinit
  ip_address = length(local.common_instances.monitoring.ip_addresses) > 0 ? element(local.common_instances.monitoring.ip_addresses, count.index) : null
}