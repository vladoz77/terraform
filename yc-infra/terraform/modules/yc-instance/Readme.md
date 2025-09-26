# Terraform Module: Yandex Cloud Compute Instance

Модуль для создания виртуальной машины в Yandex Cloud с поддержкой дополнительных дисков, сетевых интерфейсов и DNS-записей.

## Структура модуля

```
modules/compute-instance/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## Input Variables

### Основные параметры

| Переменная | Тип | Обязательно | По умолчанию | Описание |
|------------|-----|-------------|--------------|-----------|
| `name` | `string` | Нет | `"yc-instance"` | Имя виртуальной машины |
| `zone` | `string` | Да | - | Зона доступности Yandex Cloud |
| `platform_id` | `string` | Нет | `"standard-v1"` | Платформа виртуальной машины |
| `core_fraction` | `number` | Нет | `20` | Гарантированная доля vCPU |
| `cores` | `number` | Нет | `2` | Количество vCPU |
| `memory` | `number` | Нет | `2` | Объем памяти (ГБ) |

### Диски

#### Boot Disk
```hcl
variable "boot_disk" {
  type = object({
    image_id = string
    type     = string
    size     = number
  })
}
```

Пример:
```hcl
boot_disk = {
  image_id = "fd8vmcue7aajpmeo39kk"  # Ubuntu 22.04
  type     = "network-hdd"
  size     = 20
}
```

#### Additional Disks
```hcl
variable "additional_disks" {
  type = list(object({
    size = number
    type = string
  }))
  default = []
}
```

Пример:
```hcl
additional_disks = [
  {
    size = 50
    type = "network-hdd"
  },
  {
    size = 100
    type = "network-ssd"
  }
]
```

### Сетевые интерфейсы

```hcl
variable "network_interfaces" {
  type = list(object({
    subnet_id           = string
    nat                 = bool
    ip_address          = optional(string)
    security_group      = optional(set(string))
    static_nat_ip_address = optional(string)
  }))
}
```

Пример:
```hcl
network_interfaces = [
  {
    subnet_id      = "e9bxxxxxxxxxxxxxxx"
    nat            = true
    security_group = ["enpxxxxxxxxxxxxxxx"]
  }
]
```

### SSH и метаданные

| Переменная | Тип | Описание |
|------------|-----|-----------|
| `ssh` | `string` | SSH-ключ для подключения |
| `tags` | `list(string)` | Теги виртуальной машины |
| `labels` | `map(string)` | Метки ресурса |
| `cloud_init` | `string` | Cloud-init конфигурация |

### DNS записи

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|-----------|
| `create_dns_record` | `bool` | `false` | Создавать DNS запись |
| `dns_zone_id` | `string` | `""` | ID DNS зоны |
| `dns_records` | `map(object({...}))` | `{}` | Конфигурация DNS записей |

## Outputs

| Output | Тип | Описание |
|--------|-----|-----------|
| `instance_id` | `string` | ID созданной виртуальной машины |
| `public_ips` | `string` | Публичный IP адрес |
| `private_ips` | `string` | Приватный IP адрес |
| `tags` | `list(string)` | Теги ВМ |
| `instance_name` | `string` | Имя ВМ |
| `fqdn` | `list(string)` | FQDN записи (если создавались) |

## Примеры использования

### Базовый пример

```hcl
module "web_server" {
  source = "./modules/compute-instance"

  name        = "web-server"
  zone        = "ru-central1-a"
  cores       = 2
  memory      = 4
  core_fraction = 20

  boot_disk = {
    image_id = "fd8vmcue7aajpmeo39kk"  # Ubuntu 22.04
    type     = "network-ssd"
    size     = 30
  }

  ssh = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E... user@example.com"

  network_interfaces = [{
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }]

  tags = ["web", "production"]
}
```

### Пример с дополнительными дисками

```hcl
module "database_server" {
  source = "./modules/compute-instance"

  name        = "db-server"
  zone        = "ru-central1-b"
  cores       = 4
  memory      = 8

  boot_disk = {
    image_id = "fd8vmcue7aajpmeo39kk"
    type     = "network-ssd"
    size     = 30
  }

  additional_disks = [
    {
      size = 100
      type = "network-ssd"
    },
    {
      size = 500
      type = "network-hdd"
    }
  ]

  ssh = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E... user@example.com"

  network_interfaces = [{
    subnet_id      = yandex_vpc_subnet.main.id
    nat            = false
    security_group = [yandex_vpc_security_group.database.id]
  }]
}
```

### Пример с Cloud-init и DNS

```hcl
module "app_server" {
  source = "./modules/compute-instance"

  name        = "app-server"
  zone        = "ru-central1-a"

  boot_disk = {
    image_id = "fd8vmcue7aajpmeo39kk"
    type     = "network-ssd"
    size     = 30
  }

  ssh = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E... user@example.com"

  cloud_init = <<-EOT
    #cloud-config
    packages:
      - nginx
      - postgresql-client
    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
  EOT

  network_interfaces = [{
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }]

  create_dns_record = true
  dns_zone_id       = yandex_dns_zone.main.zone_id
  dns_records = {
    "app" = {
      name = "app.example.com."
      ttl  = 300
      type = "A"
    }
  }
}
```

### Пример с несколькими сетевыми интерфейсами

```hcl
module "multi_nic_instance" {
  source = "./modules/compute-instance"

  name = "multi-nic-vm"
  zone = "ru-central1-a"

  boot_disk = {
    image_id = "fd8vmcue7aajpmeo39kk"
    type     = "network-ssd"
    size     = 30
  }

  network_interfaces = [
    {
      subnet_id = yandex_vpc_subnet.public.id
      nat       = true
    },
    {
      subnet_id      = yandex_vpc_subnet.private.id
      nat            = false
      ip_address     = "192.168.10.10"
      security_group = [yandex_vpc_security_group.private.id]
    }
  ]

  ssh = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E... user@example.com"
}
```

## Зависимости

Модуль требует настройки провайдера Yandex Cloud:

```hcl
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.134.0"
    }
  }
  required_version = ">= 1.9.8"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}
```

## Примечания

1. Модуль автоматически создает зависимость между дополнительными дисками и виртуальной машиной
2. Для использования DNS записей необходимо предварительно создать DNS зону
3. Cloud-init конфигурация должна быть в формате YAML
4. Все диски создаются в той же зоне, что и виртуальная машина
5. Виртуальная машина создается с политикой прерываемости (`preemptible = true`)