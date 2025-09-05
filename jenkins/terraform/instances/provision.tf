# Ресурс для генерации динамического inventory-файла Ansible
resource "local_file" "inventory" {
  content = templatefile("./templates/inventory.tftpl",
    {
      jenkins-server  = flatten(module.jenkins[*].public_ips)
      jenkins-agent = flatten(module.jenkins-agent[*].public_ips)
      username   = var.username
    }
  )
  filename   = "../../ansible/inventory/production/inventory.ini"
  depends_on = [module.jenkins, module.jenkins-agent]
}

