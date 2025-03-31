terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"
}

resource "yandex_compute_disk" "additional_disks" {
  count = length(var.additional_disks)

  name = lower("${var.name}-disk-${count.index}") 
  type = var.additional_disks[count.index].type
  size = var.additional_disks[count.index].size
  zone = var.zone
}

# Instance config
resource "yandex_compute_instance" "instance" {
  # count = var.count_vm

  name                      = var.name
  labels                    = var.labels
  allow_stopping_for_update = true
  platform_id               = var.platform_id
  zone                      = var.zone

  resources {
    core_fraction       = var.core_fraction
    cores               = var.cores
    memory              = var.memory
  }

  

  boot_disk {
    initialize_params {
      image_id = var.boot_disk["disk_image_id"]
      size     = var.boot_disk["disk_size"]
      type     = var.boot_disk["disk_type"]
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.additional_disks[*].id

    content{
      disk_id = secondary_disk.value
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnet_id           = network_interface.value.subnet_id
      nat                 = network_interface.value.nat
      ip_address          = network_interface.value.ip_address
      security_group_ids = network_interface.value.security_group
    }
  }



  metadata = {
    ssh-keys = var.ssh
    tags     = join(",", var.tags)
    user-data = local.cloud_init
  }

  scheduling_policy {
    preemptible = true
  }

  depends_on = [yandex_compute_disk.additional_disks]
}

