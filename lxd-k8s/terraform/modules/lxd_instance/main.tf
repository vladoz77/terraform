# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 3.0.1"
    }
  }
}

# Create dedicated storage volumes for additional disks
resource "lxd_storage_volume" "volumes" {
  for_each = var.volumes

  name = "${var.instance.name}-${each.key}"
  pool = each.value.pool
  content_type  = "block"

  config = {
    size = each.value.size
  }
}

# Create LXD instance (virtual machine)
resource "lxd_instance" "instance" {
  name      = var.instance.name
  image     = var.instance.image
  type      = "virtual-machine"
  profiles  = [var.lxd_profile_name]
  ephemeral = false

  config = {
    "limits.cpu"     = tostring(var.instance.cpu)
    "limits.memory"  = var.instance.memory
    "user.user-data" = var.instance.cloud_init
  }

  # Add root disk
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.instance.root_disk_source
      size = var.instance.root_disk_size
    }
  }

  # Add cloud init device
  device {
    name = "cloud-init"
    type = "disk"
    properties = {
      source = "cloud-init:config"
    }
  }

  # Add additional volumes as block devices
  dynamic "device" {
    for_each = var.volumes

    content {
      name = device.key
      type = "disk"
      properties = {
        pool   = device.value.pool
        source = lxd_storage_volume.volumes[device.key].name
      }
    }
  }

  # Configure network interface
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = var.network_name
      "ipv4.address" = var.instance.ipv4_address
    }
  }
}

# Wait until instance becomes available via SSH
resource "null_resource" "wait_for_ssh" {
  depends_on = [lxd_instance.instance]

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