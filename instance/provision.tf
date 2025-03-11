resource "local_file" "inventory" {
  content = templatefile("./inventory.tftpl",
    {
      instance = flatten(module.yandex-instance[*].public_ips)
    }
  )
  filename   = "./provision/inventory.ini"
  depends_on = [module.yandex-instance]
}

resource "null_resource" "run-ansible" {
  triggers = {
    id = join(",", flatten([
      module.yandex-instance[*].instance_id
      ]))
  }

  provisioner "local-exec" {
    command = <<EOT
      for ip in $(cat provision/inventory.ini | grep -E '^[0-9]' | awk '{print $1}'); do
        until nc -zv $ip 22; do
          echo "Waiting for SSH on $ip..."
          sleep 5
        done
      done
    EOT
  }

  # Запустим плейбук
  provisioner "local-exec" {
    command = "ansible-playbook -i provision/inventory.ini provision/playbook.yaml -u ${var.username}"
  }

  depends_on = [module.yandex-instance, local_file.inventory]
}