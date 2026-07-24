# Terraform модуль lxd_instance

Модуль создаёт LXD instance типа virtual-machine и настраивает для него сетевой интерфейс, корневой диск, дополнительные блочные тома и cloud-init.

## Что делает модуль

Модуль выполняет следующие действия:
- создаёт ресурс LXD instance с именем, образом, CPU и памятью;
- добавляет корневой диск через устройство типа `disk`;
- подключает диск `cloud-init:config` для передачи user-data;
- создаёт дополнительные storage volumes и подключает их как блочные устройства;
- добавляет сетевой интерфейс `eth0` с фиксированным IPv4 адресом;
- ждёт появления SSH на заданном IP адресе через локальный `local-exec`.

## Важные детали

- В текущей реализации тип экземпляра зафиксирован как `virtual-machine`.
- Сетевой интерфейс всегда создаётся как `eth0`.
- Проверка доступности выполняется по порту `22` через `nc`.
- Для работы модуля требуется уже существующая LXD сеть, имя которой передаётся в переменной `network_name`.

## Требования

- Terraform >= 1.0
- провайдер `terraform-lxd/lxd` версии >= 3.0.1
- LXD с доступным storage pool и сетью
- утилита `nc` на машине, где запускается Terraform

Исходные файлы модуля:

- [main.tf](main.tf)
- [variables.tf](variables.tf)
- [outputs.tf](outputs.tf)

## Входные переменные

### Обязательные

#### `network_name`
- тип: `string`
- описание: имя LXD сети, к которой подключается инстанс

#### `instance`
- тип: `object`
- описание: параметры экземпляра

Поле `instance` содержит:

```hcl
instance = {
  name             = string
  image            = string
  ipv4_address     = string
  cpu              = number
  memory           = string
  cloud_init       = string
  root_disk_source = string
  root_disk_size   = string
}
```

### Опциональные

#### `lxd_profile_name`
- тип: `string`
- значение по умолчанию: `"instance_profile"`
- описание: имя профиля LXD, который будет применён к инстансу

#### `volumes`
- тип: `map(object({ size = string, pool = string }))`
- значение по умолчанию: `{}`
- описание: дополнительные тома, которые будут созданы и подключены к инстансу

#### `wait_timeout`
- тип: `number`
- значение по умолчанию: `300`
- описание: таймаут ожидания SSH в секундах

## Пример использования

```hcl
module "k8s_master" {
  source = "../modules/lxd_instance"

  network_name = "lxdbr0"

  instance = {
    name             = "k8s-master-1"
    image            = "ubuntu:22.04"
    ipv4_address     = "192.168.200.10"
    cpu              = 2
    memory           = "4GB"
    cloud_init       = file("${path.module}/cloud-init.yaml")
    root_disk_source = "default"
    root_disk_size   = "20GB"
  }

  volumes = {
    data = {
      size = "50GB"
      pool = "default"
    }
  }

  wait_timeout = 600
}
```

## Выходы

- `instance_name` — имя созданного LXD instance
- `ipv4_address` — статический IPv4 адрес, переданный в модуль
- `volumes` — информация о созданных дополнительных томах

## Полезные команды

```bash
# посмотреть список инстансов
lxc list

# посмотреть детали инстанса
lxc config show k8s-master-1

# посмотреть сеть
lxc network show lxdbr0
```

## Замечания

- Если SSH не становится доступен, проверьте:
  - что инстанс успешно создался;
  - что сетевой адрес действительно доступен в LXD сети;
  - что `nc` установлен и доступен;
  - что значение `wait_timeout` достаточно велико.

