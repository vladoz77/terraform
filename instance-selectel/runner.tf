#Создать загрузочный сетевой диск⁠ plane
resource "openstack_blockstorage_volume_v3" "boot_disk_runner" {
  count                = local.runner.count
  name                 = "boot-volume-for-server"
  size                 = local.runner.disk_size
  image_id             = data.openstack_images_image_v2.os_image.id
  volume_type          = local.runner.disk_type
  availability_zone    = "${var.zone_id}a"
  enable_online_resize = true
}

# Создать флейвор backend с сетевым диском⁠ backend
resource "openstack_compute_flavor_v2" "runner_flavor" {
  name      = "${local.runner.name}-flavor"
  vcpus     = local.runner.vcpu
  ram       = local.runner.memory
  disk      = 0
  is_public = false
}


# Создать облачный сервер⁠ backend
resource "openstack_compute_instance_v2" "runner" {
  name              = "${local.runner.name}-${count.index}"
  flavor_id         = openstack_compute_flavor_v2.runner_flavor.id
  availability_zone = "${var.zone_id}a"
  image_id          = data.openstack_images_image_v2.os_image.id
  count             = local.runner.count
  user_data         = local.runner.cloud_init

  network {
    port = openstack_networking_port_v2.runner_port[count.index].id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.boot_disk_runner[count.index].id
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

# Создадим порты для backend
resource "openstack_networking_port_v2" "runner_port" {
  name           = "port"
  network_id     = openstack_networking_network_v2.private-network.id
  admin_state_up = "true"
  count          = local.runner.count

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_1.id
  }
}

# Создать публичный IP-адрес runner
resource "openstack_networking_floatingip_v2" "runner_public_ip" {
  depends_on = [openstack_networking_router_interface_v2.router_interface_1]
  pool       = "external-network"
  count      = local.runner.count
}

resource "openstack_networking_floatingip_associate_v2" "association_runner" {
  count       = local.runner.count
  port_id     = openstack_networking_port_v2.runner_port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.runner_public_ip[count.index].address
}