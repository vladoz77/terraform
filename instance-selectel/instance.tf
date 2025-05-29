# Получить образ⁠ диска
data "openstack_images_image_v2" "os_image" {
  name        = "Ubuntu 20.04 LTS 64-bit"
  most_recent = true
  visibility  = "public"

  depends_on = [
    selectel_iam_serviceuser_v1.instance-sa
  ]
}

#Создать загрузочный сетевой диск⁠
resource "openstack_blockstorage_volume_v3" "boot_disk" {
  count = local.count
  name                 = "boot-volume-for-server"
  size                 = local.instance.disk_size
  image_id             = data.openstack_images_image_v2.os_image.id
  volume_type          = local.instance.disk_type
  availability_zone    = "${var.zone_id}a"
  enable_online_resize = true
}

# Создать флейвор с сетевым диском⁠
resource "openstack_compute_flavor_v2" "flavor" {
  name      = "instance-flavor"
  vcpus     = local.instance.vcpu
  ram       = local.instance.memory
  disk      = 0
  is_public = false
}

# Создать облачный сервер⁠
resource "openstack_compute_instance_v2" "server_1" {
  name              = "${local.instance.name}-${count.index}"
  flavor_id         = openstack_compute_flavor_v2.flavor.id
  key_pair          = selectel_vpc_keypair_v2.ssh_key.name
  availability_zone = "${var.zone_id}a"
  image_id = data.openstack_images_image_v2.os_image.id
  count = local.count
  user_data = local.instance.cloud_init

  network {
    port = openstack_networking_port_v2.port[count.index].id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.boot_disk[count.index].id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}