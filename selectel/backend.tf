#Создать загрузочный сетевой диск⁠ plane
resource "openstack_blockstorage_volume_v3" "boot_disk_backend" {
  count                = local.backend.count
  name                 = "boot-volume-for-server"
  size                 = local.backend.disk_size
  image_id             = data.openstack_images_image_v2.os_image.id
  volume_type          = local.backend.disk_type
  availability_zone    = "${var.zone_id}a"
  enable_online_resize = true
}

# Создать флейвор backend с сетевым диском⁠ backend
resource "openstack_compute_flavor_v2" "backend_flavor" {
  name      = "${local.backend.name}-flavor"
  vcpus     = local.backend.vcpu
  ram       = local.backend.memory
  disk      = 0
  is_public = false
}


# Создать облачный сервер⁠ backend
resource "openstack_compute_instance_v2" "backend" {
  name              = "${local.backend.name}-${count.index}"
  flavor_id         = openstack_compute_flavor_v2.backend_flavor.id
  availability_zone = "${var.zone_id}a"
  image_id          = data.openstack_images_image_v2.os_image.id
  count             = local.backend.count
  user_data         = local.backend.cloud_init

  network {
    port = openstack_networking_port_v2.backend_port[count.index].id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.boot_disk_backend[count.index].id
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

resource "openstack_networking_port_v2" "backend_port" {
  name           = "port"
  network_id     = openstack_networking_network_v2.private-network.id
  admin_state_up = "true"
  count          = local.backend.count

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

# Создать публичный IP-адрес backend
resource "openstack_networking_floatingip_v2" "backend_public_ip" {
  depends_on = [openstack_networking_router_interface_v2.router_interface_1]
  pool       = "external-network"
  count      = local.backend.count
}

resource "openstack_networking_floatingip_associate_v2" "association_backend" {
  count       = local.backend.count
  port_id     = openstack_networking_port_v2.backend_port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.backend_public_ip[count.index].address
}