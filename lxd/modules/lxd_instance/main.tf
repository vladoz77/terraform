resource "lxd_instance" "instance" {
  profiles = [var.instance.profile]
  image    = var.instance.image
  name     = var.instance.name
  type     = "virtual-machine"

  limits = {
    cpu = var.instance.cpu
    memory = var.instance.memory
  }

  # Динамическое добавление дисков
  dynamic "device" {
    for_each = var.attached_volume
    content {
      name = device.key
      type = "disk"

      properties = {
        pool   = device.value.pool
        source = device.value.name
      }
    }
  }

  # Сетевые интерфейсы
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
      "ipv4.address" = var.instance.ipv4_address
    }
  }

  config = {
    "user.user-data" = var.instance.cloud_init
  }
}