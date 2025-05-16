# Вывод информации о виртуальных машинах Jenkins

# Публичные IP-адреса виртуальных машин Jenkins
output "jenins_public_ip" {
  value = module.jenkins[*].public_ips    # Список публичных IP-адресов всех инстансов Jenkins
}

# Публичные IP-адреса виртуальных машин Jenkins Agent
output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips     # Список публичных IP-адресов всех агентов Jenkins
}

# Вывод информации о id сети
output "network_id" {
  value = yandex_vpc_network.network.id
}

# Вывод zone_id
output "zone_id" {
  value = yandex_dns_zone.zone1.id
}









