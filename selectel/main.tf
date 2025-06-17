# Получаем внешнюю сеть
data "openstack_networking_network_v2" "external_network" {
  name = "external-network"
}

# Получаем внешние подсети
data "openstack_networking_subnet_ids_v2" "external_subnet" {
  network_id = data.openstack_networking_network_v2.external_network.name
}

data "openstack_images_image_v2" "os_image" {
  name        = local.os_version
  most_recent = true
  visibility  = "public"
}

module "cloudinit" {
  source = "./modules/cloudinit_devops_factory"

  username   = var.selectel_username
  password   = var.selectel_password
  account_id = local.selectel_domain_name
}

module "network" {
  source = "./modules/network"

  cidr                = "172.16.10.0/24"
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

module "plane" {
  source = "./modules/instance"
  count  = 1

  instance_name = "instance-plane-${count.index}"
  disk_size     = 100
  disk_type     = "basic.ru-7a"
  os_image_id   = data.openstack_images_image_v2.os_image.id
  vcpu          = 2
  memory        = 2048
  network_id    = module.network.network_id
  subnet_id     = module.network.subnet_id
  port_id       = module.network.port_id
  zone_id       = var.zone_id
  cloud_init    = module.cloudinit.cloudinit

  depends_on = [module.network]
}

# module "backend" {
#   source = "./modules/instance"
#   count = 1

#   instance_name = "instance-backend-${count.index}"
#   disk_size = 100
#   disk_type = "basic.ru-7a"
#   os_image_id = data.openstack_images_image_v2.os_image.id
#   vcpu = 2
#   memory = 2048
#   network_id = module.network.network_id
#   subnet_id = module.network.subnet_id
#   zone_id = var.zone_id
#   cloud_init = module.cloudinit.cloudinit

#   depends_on = [ module.network ]
# }

# module "runner" {
#   source = "./modules/instance"
#   count = 1

#   instance_name = "instance-runner-${count.index}"
#   disk_size = 50
#   disk_type = "basic.ru-7a"
#   os_image_id = data.openstack_images_image_v2.os_image.id
#   vcpu = 2
#   memory = 2048
#   network_id = module.network.network_id
#   subnet_id = module.network.subnet_id
#   zone_id = var.zone_id
#   cloud_init = module.cloudinit.cloudinit

#   depends_on = [ module.network ]
# }

# module "monitoring" {
#   source = "./modules/instance"
#   count = 1

#   instance_name = "instance-monitoring-${count.index}"
#   disk_size = 50
#   disk_type = "basic.ru-7a"
#   os_image_id = data.openstack_images_image_v2.os_image.id
#   vcpu = 2
#   memory = 2048
#   network_id = module.network.network_id
#   subnet_id = module.network.subnet_id
#   zone_id = var.zone_id
#   cloud_init = module.cloudinit.cloudinit

#   depends_on = [ module.network ]
# }