# Ресурс для генерации динамического inventory-файла Ansible
resource "local_file" "inventory" {
  # Используем шаблон для генерации содержимого файла
  content = templatefile("./provision/inventory.tftpl",
    {
      # Передаем в шаблон публичные IP-адреса Jenkins-серверов
      jenkins       = flatten(module.jenkins[*].public_ips)
      # Передаем публичные IP-адреса агентов Jenkins
      jenkins-agent = flatten(module.jenkins-agent[*].public_ips)
      # Имя пользователя для подключения
      username   = var.username
    }
  )
  # Путь для сохранения inventory-файла
  filename   = "./provision/inventory.ini"
  # Ожидаем создания Jenkins и агентов перед генерацией файла
  depends_on = [module.jenkins, module.jenkins-agent]
}

# Ресурс для выполнения Ansible-плейбуков
# resource "null_resource" "run-ansible" {
#   # Триггеры для повторного запуска при изменении ID инстансов
#   triggers = {
#     id = join(",", flatten([
#       module.jenkins[*].instance_id,
#       module.jenkins-agent[*].instance_id
#       ]))
#   }
# }
#   # Проверка доступности SSH на всех хостах перед выполнением плейбуков
#   provisioner "local-exec" {
#     command = <<EOT
#       # Извлекаем все IP-адреса из inventory-файла
#       for ip in $(cat provision/inventory.ini | grep -E '^[0-9]' | awk '{print $1}'); do
#         # Ожидаем пока порт 22 (SSH) не станет доступен
#         until nc -zv $ip 22; do
#           echo "Waiting for SSH on $ip..."
#           sleep 5
#         done
#       done
#     EOT
#   }

#   # Выполняем плейбук

#   provisioner "local-exec" {
#     command = <<EOT
#       echo ${var.ansible_secret} > ./vault_secret
#       ansible-playbook -i provision/inventory.ini provision/provision-all.yaml -u ${var.username} --vault-password-file ./vault_secret
#       rm -r ./vault_secret
#     EOT
#   }

#   # Зависимости - ждем создания всех ресурсов перед выполнением
#   depends_on = [
#     module.jenkins,         # Модуль Jenkins-сервера
#     module.jenkins-agent,   # Модуль Jenkins-агентов
#     local_file.inventory    # Сгенерированный inventory-файл
#   ]
# }