# Terraform — Jenkins (YC)

**Кратко**
- Этот набор Terraform-конфигураций развертывает Jenkins-сервер(а) и Jenkins-agent'ы в Yandex Cloud, используя модуль `terraform/modules/yc-instance`.
- Секреты для доступа к Yandex Cloud извлекаются из HashiCorp Vault (AppRole).
- Сетевые параметры берутся из удалённого состояния `network.tfstate` (S3-бэкенд).
- В результате генерируется Ansible inventory (`ansible/inventory/jenkins/<environment>/inventory.ini`).

**Структура**
- `main.tf` — основная логика: провайдеры, data-ресурсы, вызов модулей `jenkins` и `jenkins-agent`, генерация inventory.
- `variables.tf` — переменные для конфигурации (role_id, secret_id, zone, username, ssh_key, platform_id, `jenkins`, `jenkins-agent` и т.д.).
- `outputs.tf` — выходные данные: публичные IP, FQDN.

**Требования**
- Terraform: `>= 1.9.8` (указано в `main.tf`).
- Провайдеры: `yandex` (pin `0.134.0` в `main.tf`) и `vault`.
- Доступ к HashiCorp Vault с AppRole (role_id/secret_id) и разрешение на чтение секретов `kv`.
 - `vault_address` задаётся переменной `var.vault_address` (по умолчанию `http://localhost:8200`) — убедитесь, что в продакшне используете безопасный адрес и TLS.
- Доступ к S3-бэкенду (Yandex Object Storage) для чтения удалённого состояния сети.
- Доступ и права в Yandex Cloud (через сервисный аккаунт, токен из Vault).

**Как это работает**
1. Terraform аутентифицируется в Vault через AppRole (`role_id` + `secret_id`) и получает `iam_token`, `cloud_id`, `folder_id`.
2. Провайдер Yandex использует эти данные и `var.zone`.
3. Конфигурация извлекает `network` из удалённого состояния для получения `subnet_id` и `zone_id`.
4. Модуль `terraform/modules/yc-instance` используется для создания Jenkins-серверов и агентов.
5. Генерируется файл inventory для Ansible в `ansible/inventory/jenkins/<environment>/inventory.ini`.

**Переменные (важные)**
- `role_id` (string) — AppRole Role ID для Vault (обязательно).
- `secret_id` (string) — AppRole Secret ID для Vault (обязательно).
- **Примечание:** `role_id` и `secret_id` помечены как `sensitive` в `variables.tf` — не выводите их в логах и не храните в открытых файлах.
- `zone` (string) — зона Yandex Cloud. Default: `ru-central1-a`.
- `username` (string) — SSH-пользователь для доступа. Default: `ubuntu`.
- `ssh_key` (string) — публичный SSH-ключ (строка). Пример: `export TF_VAR_ssh_key="$(cat ~/.ssh/id_rsa.pub)"`.
- `platform_id` (string) — platform id Yandex Cloud (обязательно).
- `environment` (string) — среда (`dev`, `stage`, `prod`). Default: `dev`.

Переменные для вложенных объектов:
- `jenkins` (object):
  - `count` — количество Jenkins-серверов (number).
  - `instance_name` — базовое имя инстанса (string).
  - `cpu`, `core_fraction`, `memory` — ресурсы.
  - `boot_disk` — объект `{ type, size, image_id }`.
  - `dns_records` — map для записи DNS (если `create_dns_record` включён в модуле).

- `jenkins-agent` (object): аналогично `jenkins` для агентов.

(Полный список и значения по умолчанию — в `variables.tf`.)

**Выходы**
- `jenins_public_ip` — список публичных IP Jenkins-серверов (массив).
- `jenkins-agent_public_ip` — список публичных IP Jenkins-агентов.
- `fqdn` — FQDN развернутых инстансов (если DNS создавался).

> Внимание: имя выхода `jenins_public_ip` содержит опечатку в конфиге — учтите это при обращении к output.

**Инструкция по запуску (локально)**
1. Установите необходимые переменные окружения или передайте `-var`/`-var-file` параметр:

```bash
export TF_VAR_role_id="<VAULT_ROLE_ID>"
export TF_VAR_secret_id="<VAULT_SECRET_ID>"
export TF_VAR_ssh_key="$(cat ~/.ssh/id_rsa.pub)"
# If Vault is not on the default address, set:
export TF_VAR_vault_address="https://vault.example.local:8200"
# Или задайте platform_id и другие переменные через -var или tfvars
```

2. Инициализируйте и проверьте план:

```bash
terraform init
terraform plan -var "platform_id=<your-platform-id>" -var "environment=dev"
```

3. Примените (внимательно проверяйте план):

```bash
terraform apply -var "platform_id=<your-platform-id>" -var "environment=dev"
```

4. После успешного `apply` проверьте сгенерированный Ansible inventory:

```bash
ls -l ansible/inventory/jenkins/${environment}/inventory.ini
cat ansible/inventory/jenkins/${environment}/inventory.ini
```

**Примеры**
- В репозитории существует шаблон `templates/jenkins-inventory.tftpl`, который используется для генерации inventory.
- Для быстрого теста можно запустить с `environment=dev` и `jenkins.count=1`, `jenkins-agent.count=1`.

- **Советы по безопасности и улучшениям**
- `vault_address` вынесён в переменную `var.vault_address` (см. `variables.tf`) — в продакшне замените значение на защищённый адрес (`https`) и настройте проверку TLS/CA.
- Переменные `role_id` и `secret_id` уже помечены как `sensitive` в `variables.tf` — не логируйте их и избегайте передачи в открытых CI-логах.
- Рекомендуется не хранить реальные `ssh_key`/`image_id` в VCS — использовать `tfvars` вне репозитория или secret manager.
- Добавить валидации для `platform_id`, `jenkins.boot_disk.image_id` и других критичных полей.
- Исправить опечатку в `outputs.tf` (`jenins_public_ip` → `jenkins_public_ip`) и задокументировать изменение (обратная совместимость).

**CI / проверка**
- Рекомендуется добавить пайплайн, который выполняет:
  - `terraform fmt -check`
  - `terraform validate`
  - `terraform plan` для `examples/` (при наличии)

**Частые проблемы и отладка**
- "Permission denied" при записи в `ansible/inventory` — проверьте права и `filename` в `local_file` (путь построен относительно корня репозитория).
- Ошибки аутентификации в Vault — проверьте `role_id`/`secret_id` и доступ к Vault из CI/локальной среды.
- Неверный `image_id` — используйте `yandex_compute_image` или UI, чтобы получить актуальные id образов.

**Дальше — возможные улучшения**
- Вынести `vault.address` в переменную и поддержать TLS/CA.
- Добавить `examples/` с готовым `tfvars` (без секретов) для быстрого старта.
- Добавить тесты интеграции (smoke tests) и автоматические проверки `terraform plan` в PR.


