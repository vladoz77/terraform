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