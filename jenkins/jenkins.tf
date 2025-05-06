# Модуль создания инстанса Jenkins
module "jenkins" {
  source = "../tf-modules/instance"  # Путь к модулю создания инстанса

  count = 1  # Количество создаваемых инстансов

  # Основные параметры инстанса
  name = "${local.jenkins.instance_name}-${count.index + 1}" # Генерация имени
  zone = local.jenkins.instance_zone
  platform_id = local.jenkins.instance_platform_id
  cores = local.jenkins.instance_core
  memory = local.jenkins.instance_memory
  core_fraction = local.jenkins.instance_core_fraction
  
  # Доступ по SSH
  ssh = "${var.username}:${var.ssh_key}"
  
  # Теги и сетевые интерфейсы
  tags  = local.jenkins.instance_tag
  network_interfaces = local.jenkins.instance_network_interface
  
  # Загрузочный диск
  boot_disk = local.jenkins.instance_boot_disk
  labels = {}  # Дополнительные метки
  
  # Дополнительные диски
  additional_disks = local.jenkins.other_disks
  
  # Переменные окружения
  env_vars = local.jenkins.environment
}