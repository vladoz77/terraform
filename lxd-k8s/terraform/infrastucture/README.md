# Terraform root module: infrastructure

Этот root module разворачивает базовую LXD-инфраструктуру для Kubernetes-кластера: создаёт LXD profile, storage pools, сеть, виртуальные машины и генерирует inventory-файл для Ansible.

## Что делает модуль

Модуль выполняет следующие шаги:

- создаёт LXD profile с именем из переменной `lxd_profile_name`;
- создаёт storage pools для root- и data-дисков;
- создаёт LXD network с заданными IPv4/IPv6, DHCP и DNS настройками;
- создаёт LXD instances для master/worker нод;
- подключает к инстансам дополнительные volumes из `var.volumes`;
- генерирует файл инвентаря Ansible в каталог `../../ansible/inventories/<environment>/inventory.ini`.

## Архитектура

Модуль использует два дочерних модуля:

- [modules/lxd_network](../modules/lxd_network/README.md) — создание LXD сети;
- [modules/lxd_instance](../modules/lxd_instance/README.md) — создание и настройка LXD инстансов.

Основные файлы этого root module:

- [main.tf](main.tf)
- [variables.tf](variables.tf)
- [locals.tf](locals.tf)
- [outputs.tf](outputs.tf)
- [environment/stage-terraform.tfvars](environment/stage-terraform.tfvars)

## Требования

- Terraform >= 1.9.0
- провайдеры:
  - `terraform-lxd/lxd` >= 3.0.1
  - `hashicorp/local` >= 2.6.2
  - `hashicorp/null` >= 3.2.4
- доступный LXD remote с именем `lxd-server-rocky`
- доступный S3 backend для хранения состояния Terraform

## Входные переменные

### `environment`
- тип: `string`
- описание: имя окружения, например `stage`, `prod`, `dev`

### `lxd_profile_name`
- тип: `string`
- значение по умолчанию: `"instance"`
- описание: имя LXD profile для создаваемых инстансов

### `lxd_image_os`
- тип: `string`
- значение по умолчанию: `""`
- описание: образ LXD, который будет использован для инстансов

### `network`
- тип: `object`
- описание: параметры LXD сети

Пример:

```hcl
network = {
  name         = "lxdbr0"
  ipv4_address = "172.10.10.1/24"
  ipv6_address = "none"
  nat          = true
  dhcp         = true
  dns_domain   = "cluster.local"
  dns_search   = "cluster.local"
}
```

### `pools`
- тип: `map(object({ pool_source = string, pool_driver = string }))`
- описание: список storage pools для создания

Пример:

```hcl
pools = {
  "root-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s"
  }
}
```

### `instances`
- тип: `map(object({...}))`
- описание: конфигурация инстансов

Структура каждого элемента:

```hcl
instances = {
  master-01 = {
    ipv4_address   = "172.10.10.2"
    cpu            = 2
    memory         = "4GB"
    root_disk_size = "20GB"
    volumes        = {}
  }
}
```

## Пример файла переменных

Пример для окружения `stage`:

```hcl
lxd_profile_name = "k8s-profile"
lxd_image_os     = "rocky-9-cloud"
environment      = "stage"

pools = {
  "root-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s"
  }
  "data-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/data-k8s"
  }
}

network = {
  name         = "lxdbr0"
  ipv4_address = "172.10.10.1/24"
  ipv6_address = "none"
  nat          = true
  dhcp         = true
  dns_domain   = "cluster.local"
  dns_search   = "cluster.local"
}

instances = {
  master-01 = {
    root_disk_size = "20GB"
    ipv4_address   = "172.10.10.2"
    cpu            = 2
    memory         = "4GB"
    volumes        = {}
  }

  worker-01 = {
    root_disk_size = "30GB"
    ipv4_address   = "172.10.10.3"
    cpu            = 2
    memory         = "4GB"
    volumes = {
      data = {
        size   = "30GB"
        pool   = "data-k8s"
      }
    }
  }
}
```

## Outputs

Модуль возвращает следующие выходы:

- `instance` — информация по созданным инстансам: имя, IPv4 и volumes;
- `storage_pools` — данные по созданным storage pools;
- `instance_names` — список имён инстансов из переменной `instances`.

## Использование

Запуск для конкретного окружения:

```bash
terraform init
terraform apply -var-file=environment/stage-terraform.tfvars
```

## Что генерируется

После успешного применения Terraform будет создан:

- LXD profile;
- storage pools;
- LXD network;
- инстансы для master/worker узлов;
- файл инвентаря Ansible по пути `../../ansible/inventories/<environment>/inventory.ini`.

## Примечания

- Имя инстанса формируется как `k8s-<key>`.
- Для каждого экземпляра используется общая LXD сеть из `module.network`.
- Для работы модуля должны быть доступны LXD remote и корректно настроенные директории для storage pools.
- Если нужно добавить новый worker или master, достаточно добавить новый элемент в `instances`.
