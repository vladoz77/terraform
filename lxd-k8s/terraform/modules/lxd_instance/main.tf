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

# Wait until instance becomes available via SSH
resource "null_resource" "wait_for_ssh" {
  depends_on = [lxd_instance.instance]

  # Триггер для пересоздания при изменении IP или имени
  triggers = {
    instance_ip   = var.instance.ipv4_address
    instance_name = var.instance.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
      echo "Waiting for SSH on ${var.instance.name} (${var.instance.ipv4_address})..."
      timeout=${var.wait_timeout}
      while [ $timeout -gt 0 ]; do
        # Сначала проверяем доступность порта
        if nc -z -w5 ${var.instance.ipv4_address} 22 2>/dev/null; then
          echo "SSH порт на ${var.instance.name} доступен"
          exit 0
        fi
        echo -n "."
        sleep 5
        timeout=$((timeout - 5))
      done
      echo "Timeout ожидания SSH на ${var.instance.name} (${var.instance.ipv4_address})" >&2
      exit 1
    EOT
  }
}