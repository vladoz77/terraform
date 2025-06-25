# MVP Проект Terraform для Selectel Cloud

Эта конфигурация Terraform использует два провайдера:

- `selectel/selectel` — для управления пользователями и SSH-ключами.
- `terraform-provider-openstack/openstack` — для сетей, ВМ и хранилища.

## Структура проекта

```plain-text
terraform-selectel-instance/
├── main.tf
├── provider.tf           # Провайдеры и авторизация
├── variables.tf          # Входные переменные
├── locals.tf             # Локальные значения
├── network.tf            # Сеть (VPC)
├── instance.tf           # Конфигурация ВМ
├── outputs.tf            # Вывод информации
├── README.md             # Этот файл
└── cloud-init.yaml       # Опционально: скрипт cloud-init
```

## Требуемые секреты

```hcl
selectel_username     = "ваш_selectel_логин"
selectel_password     = "ваш_selectel_пароль"
selectel_domain_name  = "ваш_selectel_домен "
project_id            = "ваш_project_id"
```

>[!Warning]
> Не сохраняйте этот файл в системе контроля версий!

## Детали инфраструктуры

### Сеть
- Приватная сеть : private-network
- Подсеть : 172.16.10.0/24
- Роутер : Подключён к внешней сети (external_network)
- Плавающий IP : Выделяется динамически из пула

### Виртуальная машина
- Имя : instance-0, instance-1 и т.д.
- ОС : Ubuntu 20.04 LTS
- Флейвор : Настроен вручную (1 vCPU, 1 ГБ ОЗУ)
- Диск : Загрузочный объём 100 ГБ
- SSH-ключ : Автоматически добавляется
- Cloud-init : Из файла cloud-init.yaml

## Как использовать

1. Инициализируйте Terraform

```bash
terraform init
```

2. Проверьте план изменений

```bash
terraform plan
```

3. Примените конфигурацию

```bash
terraform apply
```
После применения вы получите список публичных IP, по которым можно подключиться через SSH:

```bash
ssh root@<публичный_ip>
```
## Удаление ресурсов

Чтобы удалить все созданные ресурсы:

```bash
terraform destroy
```
