resource "local_file" "inventory" {
  content = templatefile("./provision/inventory.tftpl",
    {
      jenkins       = flatten(module.jenkins[*].public_ips)
      jenkins-agent = flatten(module.jenkins-agent[*].public_ips)
      username   = var.username
    }
  )
  filename   = "./provision/inventory.ini"
  depends_on = [module.jenkins, module.jenkins-agent]
}

resource "null_resource" "run-ansible" {
  triggers = {
    id = join(",", flatten([
      module.jenkins[*].instance_id,
      module.jenkins-agent[*].instance_id
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
    command = "ansible-playbook -i provision/inventory.ini provision/provision.yaml -u ${var.username}"
  }

  depends_on = [module.jenkins, module.jenkins-agent, local_file.inventory]
}