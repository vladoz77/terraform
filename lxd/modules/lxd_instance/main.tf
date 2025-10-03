resource "lxd_profile" "vm" {
  name = "vm-${var.instance.name}"

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.instance.root_pool
      size = var.instance.root_pool_size
    }
  }
}

resource "lxd_volume" "volume" {
  for_each = var.volumes
  
  name         = "${var.instance.name}-${each.key}"  
  pool         = var.storage_pool
  content_type = "block"
  
  config = {
    size = each.value.size
  }
}

# Создаем instance
resource "lxd_instance" "instance" {
  name = var.instance.name
  image = var.instance.image
  type = var.instance.type
  profiles = [lxd_profile.vm.name]
  ephemeral = false

  limits = {
    cpu    = var.instance.cpu
    memory = var.instance.memory
  }

  # Динамическое добавление дополнительных дисков
  dynamic "device" {
    for_each = var.volumes
    
    content {
      name = device.key
      type = "disk"
      properties = {
        source = lxd_volume.volume[device.key].name
        pool   = var.storage_pool
      }
    }
  }

  # Сетевой интерфейс
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

  depends_on = [lxd_volume.volume]
}
