# Модуль создания инстанса Jenkins агента
module "jenkins-agent" {
  source = "../tf-modules/instance"  # Путь к модулю создания инстанса

  count = 1  # Количество создаваемых инстансов

  # Основные параметры инстанса
  name = "${local.jenkins-agent.instance_name}-${count.index + 1}"
  zone = local.jenkins-agent.instance_zone
  platform_id = local.jenkins-agent.instance_platform_id
  cores = local.jenkins-agent.instance_core
  memory = local.jenkins-agent.instance_memory
  core_fraction = local.jenkins-agent.instance_core_fraction
  
  # Доступ по SSH
  ssh = "${var.username}:${var.ssh_key}"
  
  # Теги и сетевые интерфейсы
  tags  = local.jenkins-agent.instance_tag
  network_interfaces = local.jenkins-agent.instance_network_interface
  
  # Загрузочный диск
  boot_disk = local.jenkins-agent.instance_boot_disk
  labels = {}  # Дополнительные метки
  
  # Дополнительные диски (пустой список)
  additional_disks = []
  
  # Переменные окружения
  env_vars = local.jenkins-agent.environment
}