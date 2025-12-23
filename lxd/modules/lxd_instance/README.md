# Terraform LXD Instance Module

Этот модуль создает виртуальную машину (instance) в LXD с поддержкой:

- Root-диска и дополнительных блоков хранения (`volumes`)
- Настройки CPU и памяти
- Сетевого интерфейса с фиксированным IP
- Профиля LXD
- Ожидания доступности SSH после создания


## Использование

Пример использования модуля:

```hcl
module "lxd_instance" {
  source = "./path_to_module"

  lxd_profile_name     = "instance_profile"
  network_name         = "lxdbr0"
  default_storage_pool = "default"

  instance = {
    name           = "vm01"
    image          = "ubuntu:22.04"
    type           = "container"
    ipv4_address   = "10.0.0.101"
    cpu            = 2
    memory         = "2GB"
    cloud_init     = file("${path.module}/cloud-init.yaml")
    root_pool_name = "default"
    root_disk_size = "10GB"
  }

  additional_volumes = {
    "data1" = {
      size = "5GB"
      pool = "default"
    }
    "data2" = {
      size = "10GB"
      pool = "storage_pool2"
    }
  }

  wait_timeout = 300
}
```

## Переменные

| Имя                    | Тип         | По умолчанию         | Описание                                                                                                                                                                                                                                                                                                                                                                                                               |
| ---------------------- | ----------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lxd_profile_name`     | string      | `"instance_profile"` | Имя LXD профиля для instance                                                                                                                                                                                                                                                                                                                                                                                           |
| `network_name`         | string      | -                    | Имя сети в LXD для сетевого интерфейса                                                                                                                                                                                                                                                                                                                                                                                 |
| `default_storage_pool` | string      | `""`                 | Storage pool по умолчанию для volume                                                                                                                                                                                                                                                                                                                                                                                   |
| `instance`             | object      | -                    | Настройки создаваемой виртуальной машины: <br>- `name` — имя instance <br>- `image` — образ <br>- `type` — тип (`container` или `virtual-machine`) <br>- `ipv4_address` — IP-адрес <br>- `cpu` — количество CPU <br>- `memory` — память, например `"2GB"` <br>- `cloud_init` — cloud-init YAML в виде строки или файла <br>- `root_pool_name` — storage pool для root-диска <br>- `root_disk_size` — размер root-диска |
| `additional_volumes`   | map(object) | `{}`                 | Дополнительные диски в формате: <br>`"имя" = { size = "10GB", pool = "default" }`                                                                                                                                                                                                                                                                                                                                      |
| `wait_timeout`         | number      | 300                  | Таймаут ожидания доступности SSH (секунды)                                                                                                                                                                                                                                                                                                                                                                             |


## Ресурсы, создаваемые модулем

* `lxd_profile.vm` — профиль LXD
* `lxd_volume.volume` — дополнительные блоки хранения
* `lxd_instance.instance` — виртуальная машина LXD
* `null_resource.wait_for_ssh` — ожидание доступности SSH

## Outputs

| Имя             | Описание                                                      |
| --------------- | ------------------------------------------------------------- |
| `instance_name` | Имя созданной виртуальной машины                              |
| `ipv4_address`  | IPv4 адрес instance                                           |
| `volumes`       | Информация о дополнительных томах: имя, размер и storage pool |

Пример:


```hcl
output "volumes" {
  value = {
    data1 = {
      name = "vm01-data1"
      size = "5GB"
      pool = "default"
    }
    data2 = {
      name = "vm01-data2"
      size = "10GB"
      pool = "storage_pool2"
    }
  }
}
```

## Примечания

* Для работы модуля требуется установленный [Terraform](https://www.terraform.io/) версии >=1.0 и провайдер LXD версии >=1.0.
* Модуль поддерживает динамическое добавление дополнительных дисков через `additional_volumes`.
* SSH проверяется с помощью `null_resource` и `local-exec`. Можно модифицировать для `remote-exec` по необходимости.
* Cloud-init можно передавать через файл с помощью функции `file()`.
* Root-диск и дополнительные диски создаются на указанных storage pools LXD.

## Пример cloud-init

```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...userkey
packages:
  - git
  - htop
runcmd:
  - echo "Hello, LXD VM!" > /etc/motd
```

## Требования

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = ">= 1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
```


