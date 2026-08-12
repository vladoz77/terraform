# Terraform модуль lxd_network

Модуль создаёт LXD network с конфигурацией IPv4/IPv6, DHCP, DNS и NAT. Он предназначен для использования в связке с модулем `lxd_instance`.

## Что делает модуль

Модуль управляет ресурсом `lxd_network` и задаёт следующие параметры:
- IPv4 адрес сети в формате CIDR;
- IPv6 адрес сети (при необходимости);
- включение/выключение NAT;
- включение DHCP;
- диапазон адресов DHCP;
- параметры DNS domain и DNS search.

## Входные переменные

Модуль принимает один объект `network` со следующими полями:

Исходные файлы модуля:

- [main.tf](main.tf)
- [variables.tf](variables.tf)
- [outputs.tf](outputs.tf)

```hcl
network = {
  name               = string
  nat                = bool
  ipv4_address       = string
  ipv6_address       = optional(string, "none")
  dhcp               = bool
  ipv4_dhcp_ranges   = optional(string, "")
  dns_domain         = optional(string, "lxd")
  dns_search         = optional(string, "lxd")
}
```

### Описание полей

- `name` — имя сети в LXD
- `nat` — включить NAT для сети
- `ipv4_address` — IPv4 подсеть в CIDR формате, например `192.168.200.1/24`
- `ipv6_address` — IPv6 подсеть, по умолчанию `"none"`
- `dhcp` — включить DHCP
- `ipv4_dhcp_ranges` — диапазон адресов DHCP, например `192.168.200.2-192.168.200.100`
- `dns_domain` — домен DNS
- `dns_search` — search domain для DNS

## Пример использования

```hcl
module "lxd_network" {
  source = "../modules/lxd_network"

  network = {
    name             = "k8s-lxd-net"
    nat              = true
    dhcp             = true
    ipv4_address     = "192.168.200.1/24"
    ipv6_address     = "none"
    ipv4_dhcp_ranges = "192.168.200.2-192.168.200.100"
    dns_domain       = "lxd"
    dns_search       = "lxd"
  }
}
```

## Пример использования вместе с модулем инстанса

```hcl
module "lxd_network" {
  source = "../modules/lxd_network"

  network = {
    name             = "k8s-lxd-net"
    nat              = true
    dhcp             = true
    ipv4_address     = "192.168.200.1/24"
    ipv4_dhcp_ranges = "192.168.200.2-192.168.200.100"
  }
}

module "k8s_master" {
  source = "../modules/lxd_instance"

  network_name = module.lxd_network.network_name

  instance = {
    name             = "k8s-master-1"
    image            = "ubuntu:22.04"
    ipv4_address     = "192.168.200.10"
    cpu              = 2
    memory           = "4GB"
    cloud_init       = "#cloud-config\npackage_update: true"
    root_disk_source = "default"
    root_disk_size   = "20GB"
  }
}
```

## Выходы

- `network_name` — имя созданной LXD сети
- `ipv4_cidr` — IPv4 подсеть в CIDR формате

## Полезные команды

```bash
# посмотреть список сетей
lxc network list

# посмотреть детали сети
lxc network show k8s-lxd-net
```

## Замечания

- Убедитесь, что подсеть не пересекается с уже существующими сетями в вашей инфраструктуре.
- Если NAT отключён, доступ к внешним сетям для инстансов может быть недоступен.
- Для работы DHCP важно правильно задать диапазон `ipv4_dhcp_ranges`.

