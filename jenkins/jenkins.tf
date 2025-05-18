# Модуль создания инстанса Jenkins
module "jenkins" {
  source = "../tf-modules/instance"  # Путь к модулю создания инстанса

  count = local.jenkins.count  # Количество создаваемых инстансов

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
  network_interfaces = [
      {
          subnet_id  = yandex_vpc_subnet.subnet.id # Подключение к подсети
          nat        = true         # Включение NAT для выхода в интернет
          static_nat_ip_address = yandex_vpc_address.jenkins_address.external_ipv4_address[0].address
          security_group = []       # Группы безопасности
          ip_address = "172.16.10.1${count.index}"
      }
    ]
  
  # Загрузочный диск
  boot_disk = local.jenkins.instance_boot_disk
  labels = {}  # Дополнительные метки
  
  # Дополнительные диски
  additional_disks = []
  
  # Переменные окружения
  env_vars = local.jenkins.environment

  # Дополнительная настройка через CloudInit
  cloud_init = ""
}