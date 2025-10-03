# 🐉 Terraform LXD Instance Module

Модуль для создания виртуальных машин в LXD с поддержкой:
- Настройки CPU, памяти
- Подключения к сети
- Множественных томов (storage volumes)
- Cloud-init
- Статических IP-адресов

---

## ✅ Особенности

- 🧩 Создание виртуальных машин (`virtual-machine`)
- 🌐 Подключение к сети с опциональным статическим IPv4
- 💾 Подключение **нескольких томов** с разными путями монтирования
- ☁️ Поддержка `cloud-init` для настройки ОС
- 📏 Ограничение ресурсов: CPU, память
- 🔐 Работает с **self-signed провайдером** `terraform-lxd/lxd`

---

## 📦 Требования

| Имя | Версия |
|-----|--------|
| Terraform | >= 1.3 |
| LXD | >= 4.0 |
| Провайдер | `terraform-lxd/lxd ~> 2.5` |

---

## 🧰 Использование

### 1. Убедись, что провайдер настроен

```hcl
# provider.tf
terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 2.5"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true
}
```

> ⚠️ Это **self-signed provider** — HashiCorp не проверяет его подпись.  
> Убедись, что ты доверяешь источнику.

---

### 2. Используй модуль

```hcl
module "web-server" {
  source = "./modules/lxd-instance"

  network_name = "lxdbr0"

  instance = {
    name         = "web-01"
    image        = "ubuntu:22.04"
    cpu          = 2
    memory       = "2GB"
    ipv4_address = "192.168.200.10"
    profile      = "default"
    cloud_init   = file("${path.module}/cloud-init.yaml")
  }

  attached_volume = {
    data = {
      pool = "app-data"
      name = "data-web-01"
      path = "/mnt/data"
    }
    logs = {
      pool = "app-data"
      name = "logs-web-01"
      path = "/var/log/app"
    }
  }
}
```

---

## 🔧 Переменные

| Имя | Описание | Тип | Обязательно | По умолчанию |
|-----|---------|-----|-------------|-------------|
| `network_name` | Имя LXD-сети (моста) | `string` | Да | — |
| `instance` | Конфигурация инстанса | `object` | Да | — |
| `attached_volume` | Тома для подключения | `map(object)` | Нет | `{}` |

### `instance` (object)

| Поле | Описание | Тип |
|------|---------|-----|
| `name` | Имя ВМ | `string` |
| `image` | Образ (например, `ubuntu:22.04`) | `string` |
| `cpu` | Количество CPU | `number` |
| `memory` | Объём памяти (например, `"2GB"`) | `string` |
| `ipv4_address` | Статический IPv4 | `string` |
| `profile` | Имя профиля | `string` |
| `cloud_init` | Содержимое `user-data` | `string` |

### `attached_volume` (map)

| Поле | Описание |
|------|---------|
| `pool` | Имя storage pool |
| `name` | Имя существующего тома |
| `path` | Путь монтирования (опционально) |

> ⚠️ Том должен быть **создан заранее** (в корне или отдельно)

---

## 📤 Outputs

| Имя | Описание |
|-----|---------|
| `vm_name` | Имя виртуальной машины |
| `vm_ipv4_address` | Назначенный IPv4-адрес |
| `vm_mac_address` | MAC-адрес инстанса |
| `vm_ipv6_address` | IPv6-адрес (если есть) |

---

## 🛠 Примеры

### Создать ВМ с одним томом

```hcl
module "db" {
  source = "./modules/lxd-instance"

  network_name = "lxdbr0"

  instance = {
    name   = "db-01"
    image  = "ubuntu:22.04"
    cpu    = 4
    memory = "4GB"
  }

  attached_volume = {
    data = {
      pool = "app-data"
      name = "data-db-01"
    }
  }
}
```

### Создать ВМ без профиля

```hcl
instance = {
  name    = "standalone"
  # profile не указан → используется default
}
```

---

## ⚠️ Ограничения

- ❌ **Тома не создаются в модуле** — только подключаются
- ❌ Не поддерживает `count`/`for_each`, если в модуле есть `lxd_volume`

---

## 📚 Дополнительно

- [Документация LXD](https://documentation.ubuntu.com/lxd/)
- [Terraform LXD Provider](https://registry.terraform.io/providers/terraform-lxd/lxd/latest)

---

