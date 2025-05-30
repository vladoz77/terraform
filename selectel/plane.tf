#Создать загрузочный сетевой диск⁠ plane
resource "openstack_blockstorage_volume_v3" "boot_disk_plane" {
  count                = local.plane.count
  name                 = "boot-volume-for-server"
  size                 = local.plane.disk_size
  image_id             = data.openstack_images_image_v2.os_image.id
  volume_type          = local.plane.disk_type
  availability_zone    = "${var.zone_id}a"
  enable_online_resize = true
}

# Создать флейвор plane 
resource "openstack_compute_flavor_v2" "flavor_plane" {
  name      = "${local.plane.name}-flavor"
  vcpus     = local.plane.vcpu
  ram       = local.plane.memory
  disk      = 0
  is_public = false
}

# Создать облачный сервер⁠ plane
resource "openstack_compute_instance_v2" "plane" {
  name              = "${local.plane.name}-${count.index}"
  flavor_id         = openstack_compute_flavor_v2.flavor_plane.id
  availability_zone = "${var.zone_id}a"
  image_id          = data.openstack_images_image_v2.os_image.id
  count             = local.plane.count
  user_data         = local.plane.cloud_init

  network {
    port = openstack_networking_port_v2.plane_port[count.index].id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.boot_disk_plane[count.index].id
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

# Создадим порты для plane
resource "openstack_networking_port_v2" "plane_port" {
  name           = "port"
  network_id     = openstack_networking_network_v2.private-network.id
  admin_state_up = "true"
  count          = local.plane.count

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}
