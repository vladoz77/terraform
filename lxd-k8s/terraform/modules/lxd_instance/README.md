# Модуль `lxd_instance`

Кратко: модуль создаёт LXD-инстанс (контейнер или виртуальную машину), профиль с корневым диском и дополнительные LXD-тома, подключает NIC и (опционально) ждёт, пока инстанс станет `Running`.

Подходит для использования в `terraform/infrastucture` где инстансы затем конфигурируются Ansible.

## Требования
- Terraform >= 1.0  
- Провайдер: `terraform-lxd/lxd` (указан в `versions.tf` модуля)  
- (Опционально) `lxc` CLI на машине, где запускается `terraform`, если вы используете встроенный `null_resource.wait_for_running`.

## Что делает модуль
- Создаёт профиль `vm-<name>` с корневым диском (profile `lxd_profile`).
- Создаёт дополнительные тома `lxd_volume` для каждого элемента `var.volumes`.
- Создаёт `lxd_instance` и подключает тома и NIC с указанным `ipv4_address`.
- Добавляет `lifecycle` (create_before_destroy, ignore_changes для config) чтобы снизить риск непреднамеренной пересоздачи при изменениях cloud-init.
- Опционально ждёт, что инстанс перейдёт в статус `Running` через `null_resource.wait_for_running`.

## Входные переменные

Все переменные объявлены в `variables.tf` модуля. Краткая сводка:

- `network_name` (string, required)  
  - Имя LXD-сети (bridge), к которой подключится NIC инстанса.

- `storage_pool` (string, required)  
  - Storage pool по умолчанию для создания дополнительных томов.

- `instance` (object, required)  
  - Объект с параметрами инстанса. Поля:
    - `name` (string) — имя инстанса (например, `k8s-master1`).
    - `image` (string) — alias образа (например, `fedora42`).
    - `type` (string) — `virtual-machine` или `container`.
    - `ipv4_address` (string) — статический IPv4, назначаемый интерфейсу.
    - `cpu` (number) — количество vCPU.
    - `memory` (string) — строка, например `2GB`/`4096MB`.
    - `cloud_init` (string) — содержимое cloud-init (user-data).
    - `root_pool` (string) — pool для корневого диска.
    - `root_pool_size` (string) — размер корневого диска, напр. `30GB`.

- `volumes` (map(object), optional)  
  - Карта дополнительных томов. Формат: ключ => { size = "10GB", pool = optional("pool-name"), path = optional("/mnt/data") }  
  - `pool` переопределяет `storage_pool` для конкретного тома.  
  - `path` (опционально) указывается как точка монтирования внутри инстанса (добавляется в `device` для LXD).

Примечание: в `variables.tf` добавлены базовые валидации (непустые значения, допустимые типы и формат размеров томов).

## Outputs

- `instance_name` — имя созданного инстанса.  
- `ipv4_address` — IPv4, переданный в `var.instance.ipv4_address`.  
- `instance_status` — статус инстанса (попытка получить значение из `lxd_instance`), либо `unknown`.  
- `volumes` — список имён созданных LXD-томов.

## Пример использования

```hcl
module "instance" {
  source       = "../modules/lxd_instance"
  network_name = module.network.network_name
  storage_pool = lxd_storage_pool.data-k8s.name

  instance = {
    name           = "k8s-master1"
    image          = "fedora42"
    type           = "virtual-machine"
    ipv4_address   = "192.168.200.10"
    cpu            = 2
    memory         = "4GB"
    cloud_init     = file("${path.module}/cloud-init.yaml")
    root_pool      = lxd_storage_pool.root-k8s.name
    root_pool_size = "30GB"
  }

  volumes = {
    data = { size = "10GB" }
    logs = { size = "20GB", pool = "pool-k8s" }
  }
}
```

## Совместимость с `terraform/infrastucture/main.tf`

Если ваш root-модуль вызывает `module "instance"` как в примере (передаёт `instance = { ... }` и `volumes = each.value.volumes`), то никаких изменений в root не требуется — интерфейс оставлен обратно совместимым.

Если вы хотите перейти на более явный интерфейс (каждое поле инстанса как отдельная переменная модуля), можно переписать `variables.tf` и обновить вызовы в root (я могу помочь с этим).

## Важные замечания и рекомендации

- `null_resource.wait_for_running` использует `lxc info` через `local-exec`. Если Terraform запускается в CI или на машине без `lxc`, этот шаг упадёт. Опции:
  - Удалить `null_resource.wait_for_running` из модуля.
  - Заменить проверку на попытку SSH/NC к IP (если cloud-init создаёт SSH доступ).
  - Сделать проверку опциональной через булеву переменную.

- `versions.tf` внутри модуля задаёт требуемые провайдеры, но основной контроль версий обычно делается в корневом `terraform` (в `terraform/infrastucture`). Проверьте, чтобы не было конфликтов версий провайдеров.

- `lifecycle.ignore_changes = ["config"]` помогает избежать пересоздания инстанса при изменениях cloud-init. Если вы хотите, чтобы cloud-init обновлялся и применялся — удалите ignore_changes и используйте другой механизм обновления.

## Отладка

- Если `terraform plan`/`apply` выдаёт ошибку по `null_resource` — временно закомментируйте его и запустите снова.  
- Для проблем с томами проверьте, что указанный `storage_pool` существует и доступен на LXD-хосте.

## Дальше (опционально)

- Я могу:
  - добавить флаг `wait_for_running` (bool) чтобы сделать `null_resource` опциональным;
  - распаковать `var.instance` в отдельные переменные модуля (чтобы улучшить читаемость и defaults);
  - добавить тесты (terratest) / CI-правило для `terraform fmt`/`validate`.
