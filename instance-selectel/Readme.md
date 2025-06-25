# Infrastructure as Code Project PLANE

> Это репозиторий с инфраструктурой как кодом (Infrastructure as Code), построенной с использованием Terraform.  
> Он позволяет создавать облачную инфраструктуру в Selectel / OpenStack, включая сеть, инстансы и автоматизацию через cloud-init.

---

## Структура проекта

```
project/
├── common_instances/     ← Общие инстансы (runner, monitoring)
│   ├── main.tf
│   ├── locals.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   └── variables.tf
│
├── instances/            ← Инстансы под конкретное окружение (plane, backend)
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── backend-config-dev.tfvars
│   │   │   └── terraform-dev.tfvars
│   │   └── prod/
│   │       ├── backend-config-prod.tfvars
│   │       └── terraform-prod.tfvars
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── terraform.tfvars
│
├── modules/              ← Переиспользуемые модули
│   ├── network/
│   ├── instance/
│   └── cloudinit_devops_factory/
│
├── README.md             ← Этот файл
└── ...
```

## Основные компоненты

| Компонент | Описание |
|----------|----------|
| `modules/network` | Создаёт приватную сеть и подсети |
| `modules/instance` | Создаёт виртуальные машины с дисками, сетью и публичным IP |
| `modules/cloudinit_devops_factory` | Генерирует cloud-init конфигурацию |
| `common_instances` | Общие инстансы (например, `runner`, `monitoring`) — создаются всегда |
| `instances` | Переменные инстансы (например, `plane`, `backend`) — управляются через окружение |


## Возможности

- Поддержка нескольких окружений: `dev`, `prod`
- Динамическое создание инстансов через `count` и `enable`
- Единая сетевая инфраструктура через модуль `network`
- Автоматизация через `cloud-init`
- Remote state в S3 (Selectel Storage)


## Переменные и секреты

Все чувствительные данные передаются через:
- `.tfvars` файлы (не коммитятся в Git!)
- Переменные окружения: `TF_VAR_*`

Пример переменных:

```hcl
selectel_username = "devops-admin"
selectel_password = "your-secret-password"
os_version        = "Ubuntu 24.04 LTS 64-bit"

instances = {
  plane = {
    enable    = true
    count     = 1
    vcpu      = 2
    memory    = 2048
    disk_size = 50
  }
}
```

## Как использовать инстансы с окружением

### 1. Перейдите в instances

```bash
cd instances
```

### 2. Инициализируйте Terraform

```bash
terraform init -backend-config=environments/dev/backend-config-dev.tfvars -reconfigure
```

### 3. Проверьте план

```bash
terraform plan -var-file=environments/dev/terraform-dev.tfvars

```

### 4. Примените изменения

```bash
terraform apply -var-file=environments/dev/terraform-dev.tfvars
```

## Как использовать common_instances

### 1. Перейдите в common_instances

```bash
cd common_instances
```

### 2. Инициализируйте Terraform

```bash
terraform init 
```

### 3. Проверьте план

```bash
terraform plan 

```

### 4. Примените изменения

```bash
terraform apply 
```

---

## Окружения

| Окружение | Файл стейта | Включает |
|-----------|-------------|----------|
| `dev`     | `dev/terraform.tfstate` | `plane`, `backend` (выключен) |
| `prod`    | `prod/terraform.tfstate` | `plane`, `backend` (включен) |
| `common`  | `prod/terraform.tfstate` | `runner`, `monitoring` (всегда включены) |

---

## Что создаётся

### Для всех окружений:
- `runner` (1 инстанс, общая роль)
- `monitoring` (1 инстанс, общая роль)

### Для `dev`:
- `plane` (1 инстанс)
- `backend` (отключен)

### Для `prod`:
- `plane` (1 инстанс)
- `backend` (1 инстанс)


