terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 3.1.0"
    }
  }
}

#Создаем загрузочный сетевой диск⁠ 
resource "openstack_blockstorage_volume_v3" "boot_disk" {
  name                 = "boot-volume-for-server"
  size                 = var.disk_size
  image_id             = var.os_image_id
  volume_type          = var.disk_type
  availability_zone    = "${var.zone_id}a"
  enable_online_resize = true
}

# Создать флейвор plane 
resource "openstack_compute_flavor_v2" "flavor" {
  name      = "${var.instance_name}-flavor"
  vcpus     = var.vcpu
  ram       = var.memory
  disk      = 0
  is_public = false
}

# Создать облачный сервер⁠ 
resource "openstack_compute_instance_v2" "instance" {
  name              = "${var.instance_name}"
  flavor_id         = openstack_compute_flavor_v2.flavor.id
  availability_zone = "${var.zone_id}a"
  image_id          = var.os_image_id
  user_data         = var.cloud_init

  network {
    port = var.port_id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.boot_disk.id
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

# Создать публичный IP-адрес plane
resource "openstack_networking_floatingip_v2" "public_ip" {
  pool       = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association" {
  port_id     = var.port_id
  floating_ip = openstack_networking_floatingip_v2.public_ip.address
}