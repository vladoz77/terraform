data "openstack_images_image_v2" "os_image" {
  name        = local.os_version
  most_recent = true
  visibility  = "public"
}

# Получаем внешнюю сеть
data "openstack_networking_network_v2" "external_network" {
  external = true
}