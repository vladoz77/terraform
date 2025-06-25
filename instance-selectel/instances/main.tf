data "openstack_images_image_v2" "os_image" {
  name        = var.os_version
  most_recent = true
  visibility  = "public"
}

module "cloudinit" {
  source = "../modules/cloudinit_devops_factory"

  username   = var.selectel_username
  password   = var.selectel_password
  account_id = var.selectel_domain_name
}

module "plane" {
  source = "../modules/instance"
  count  = var.instances.plane.enable ? ( length(var.instances.plane.ip_addresses) > 0 ? length(var.instances.plane.ip_addresses) : var.instances.plane.count ) : 0

  instance_name = "plane-${var.environment}-${count.index}"
  disk_size     = var.instances.plane.disk_size
  disk_type     = "basic.ru-7a"
  os_image_id   = data.openstack_images_image_v2.os_image.id
  vcpu          = var.instances.plane.vcpu
  memory        = var.instances.plane.memory
  network_id    = data.terraform_remote_state.network.outputs.network_id
  subnet_id     = data.terraform_remote_state.network.outputs.subnet_id
  zone_id       = var.zone_id
  cloud_init    = module.cloudinit.cloudinit
  ip_address    = length(var.instances.plane.ip_addresses) > 0 ? element(var.instances.plane.ip_addresses, count.index) : null

}

module "backend" {
  source = "../modules/instance"
  count = var.instances.backend.enable ? ( length(var.instances.backend.ip_addresses) > 0 ? length(var.instances.backend.ip_addresses) : var.instances.backend.count ) : 0

  instance_name = "backend-${var.environment}-${count.index}"
  disk_size = var.instances.backend.disk_size
  disk_type = "basic.ru-7a"
  os_image_id = data.openstack_images_image_v2.os_image.id
  vcpu = var.instances.backend.vcpu
  memory = var.instances.backend.memory
  network_id = data.terraform_remote_state.network.outputs.network_id
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
  zone_id = var.zone_id
  cloud_init = module.cloudinit.cloudinit
  ip_address = length(var.instances.backend.ip_addresses) > 0 ? element(var.instances.backend.ip_addresses, count.index) : null

}

