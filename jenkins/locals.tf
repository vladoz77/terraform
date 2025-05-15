# Локальные переменные для конфигурации инфраструктуры
locals {
  # Конфигурация сети
  network = {
    network_name = "network"         # Название создаваемой сети
    network_subnet = "network_subnet" # Название подсети
    network_cidr = "172.16.10.0/24"  # CIDR блок для подсети
  }

  # Конфигурация Jenkins сервера
  jenkins = {
    count = 1
    instance_name = "jenkins-vm"      # Имя инстанса
    instance_zone = "ru-central1-a"   # Зона доступности
    instance_platform_id = "standard-v1" # Тип платформы
    instance_core = 2                # Количество vCPU
    instance_memory = 8               # Объем RAM (ГБ)
    instance_core_fraction = 20       # Гарантированная доля vCPU
    instance_disk_type = "network-hdd" # Тип диска
    instance_disk_size = 20           # Размер диска (ГБ)
    instance_image_id = "fd81hgrcv6lsnkremf32" # ID образа
    instance_tag = []                 # Метки инстанса
    
    # Конфигурация загрузочного диска
    instance_boot_disk = {
      disk_type = "network-hdd"
      disk_size = 20
      disk_image_id = "fd81hgrcv6lsnkremf32"
    }
    
    # Переменные окружения
    environment = {
      DB_HOST = "db.home.local"  # Хост БД
      APP_ENV = "test"           # Окружение приложения
    }
  }

  # Конфигурация Jenkins агента
  jenkins-agent = {
    count = 1
    instance_name = "jenkins-agent-vm"
    instance_zone = "ru-central1-a"
    instance_platform_id = "standard-v1"
    instance_core = 2
    instance_memory = 2
    instance_core_fraction = 20
    instance_disk_type = "network-hdd"
    instance_disk_size = 20
    instance_image_id = "fd81hgrcv6lsnkremf32"
    instance_tag = []
    
    instance_boot_disk = {
      disk_type = "network-hdd"
      disk_size = 20
      disk_image_id = "fd81hgrcv6lsnkremf32"
    }
    
    
    environment = {
      AGENT = "jenkins"    # Идентификатор агента
      APP_ENV = "test"     # Окружение приложения
    }
  }
}