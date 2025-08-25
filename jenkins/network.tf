# Создание виртуальной частной облачной сети (VPC) в Yandex Cloud
resource "yandex_vpc_network" "network" {
  name = local.network.network_name  # Имя сети берется из локальной переменной
}

# Публичный статический адрес для jenkins
resource "yandex_vpc_address" "jenkins_address" {
  name = "jenkins_address"
  external_ipv4_address {
    zone_id = var.zone
  }
}


# Создание подсети в созданной VPC сети
resource "yandex_vpc_subnet" "subnet" {
  name           = local.network.network_subnet  # Имя подсети из локальной переменной
  zone           = var.zone  # Зона доступности, задается переменной
  v4_cidr_blocks = ["172.16.10.0/24"]  # Диапазон IP-адресов подсети
  network_id     = yandex_vpc_network.network.id  # ID родительской сети
}

# Создание публичной DNS зоны
resource "yandex_dns_zone" "zone1" {
  name        = "zone1"  # Внутреннее имя зоны в Yandex Cloud
  description = "zone for my service"  # Описание зоны

  zone             = "home-local.site."  # Доменное имя зоны (заканчивается точкой)
  public           = true  # Публичная зона (доступна из интернета)
  private_networks = [yandex_vpc_network.network.id]  # Привязка к частной сети

  deletion_protection = true
}

# DNS запись типа A для сервиса Jenkins
resource "yandex_dns_recordset" "jenkins_record" {
  zone_id = yandex_dns_zone.zone1.id  # Ссылка на созданную DNS зону
  name    = "jenkins.home-local.site."  # Полное доменное имя
  type    = "A"  # Тип записи - IPv4 адрес
  ttl     = 300  # Время жизни записи в секундах
  data    = [module.jenkins[0].public_ips[0]]  # Публичный IP адрес Jenkins
}

resource "yandex_dns_recordset" "home_local_records" {
  zone_id = yandex_dns_zone.zone1.id  
  name    = "*.yc.home-local.site."  
  type    = "A"  
  ttl     = 300  
  data    = [module.jenkins[0].public_ips[0]]  
}

# resource "yandex_dns_recordset" "nexus_record" {
#   zone_id = yandex_dns_zone.zone1.id  
#   name    = "nexus.home-local.site."  
#   type    = "A"  
#   ttl     = 300  
#   data    = [module.jenkins[0].public_ips[0]]  
# }

# resource "yandex_dns_recordset" "registry_record" {
#   zone_id = yandex_dns_zone.zone1.id  
#   name    = "registry.home-local.site."  
#   type    = "A"  
#   ttl     = 300  
#   data    = [module.jenkins[0].public_ips[0]]  
# }