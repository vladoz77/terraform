## Кратко — зачем этот репозиторий

Это небольшая инфраструктурная конфигурация Terraform + Ansible. Terraform создает VPC, подсеть и одну или несколько VM через модуль `../tf-modules/instance`, сохраняет remote state в S3-бэкенд (Yandex Object Storage) и затем запускает локальный Ansible-плейбук для первоначальной настройки хостов.

## Структура (ключевые файлы)
- `provider.tf` — провайдеры и remote-state; здесь же читаются секреты из Vault (см. `data.vault_kv_secret_v2.yc_creds`).
- `main.tf` — создание сети, подсети и вызов модуля `module "yandex-instance"`.
- `provision.tf` — генерирует `provision/inventory.ini` (шаблон `inventory.tftpl`) и содержит `null_resource` с `local-exec`, который ждёт открытия SSH и вызывает Ansible.
- `provision/playbook.yaml` — Ansible playbook (устанавливает nginx, копирует шаблоны из `provision/template`).
- `provision/group_vars/instance.yaml` — переменные Ansible (packages, listening_port, site_directory и т.д.).
- `provision/template/*.j2` — Jinja2 шаблоны для index и nginx-конфигурации.
- `terraform.tfvars` / `variables.tf` / `locals.tf` — переменные и значения по умолчанию.

## Быстрая рабочая инструкция (на машине разработчика)
1. Убедитесь, что локально доступен Vault (provider в `provider.tf` использует `http://127.0.0.1:8200`) и что секреты доступны: `role_id` и `secret_id` либо в `terraform.tfvars`, либо через окружение.
2. Инициализировать Terraform:

   terraform init

3. Проверить план (можно явно указать файл переменных):

   terraform plan -var-file=terraform.tfvars

4. Применить (внимание: после успешного создания инстансов Terraform запустит Ansible автоматически через `null_resource`):

   terraform apply -var-file=terraform.tfvars

5. Локально запустить Ansible-плейбук (если нужно отладить отдельно):

   ansible-playbook -i provision/inventory.ini provision/playbook.yaml -u <username>

Замечание: `null_resource` в `provision.tf` ждёт открытия 22 порта (netcat) и затем вызывает `ansible-playbook`; если хотите отключить автоматический прогон — временно удалите/закомментируйте `null_resource.run-ansible`.

## Важные интеграции / зависимости
- Vault (локально) — используется для загрузки Yandex credentials: `data.vault_kv_secret_v2.yc_creds.data["iam_token"]`, `cloud_id`, `folder_id`. Без доступного Vault Terraform упадёт на этапе `init`/`plan` при обращении к этим данным.
- Remote state — S3 backend, endpoint: `https://storage.yandexcloud.net`. Для некоторых версий Terraform специально включены флаги `skip_*` (см. комментарии в `provider.tf`).
- Ansible — плейбук ожидает инвентори в `provision/inventory.ini`, который генерируется автоматически из `inventory.tftpl`.

## Проектные конвенции и полезные примеры
- Модуль VM находится в `../tf-modules/instance` (в `main.tf` используется `module "yandex-instance"`). Изменять конфигурацию инстанса — в `locals.tf`/модуле.
- SSH ключи/пользователь: переменные `username` и `ssh_key` (`variables.tf`). Пример использования при ручном запуске Ansible: `-u ubuntu`.
- Inventory template: `inventory.tftpl` генерирует простой INI с секцией `[instance]` и IP-адресами — Ansible ожидает IP в первой колонке (см. `provision.tf` и парсер `grep -E '^[0-9]' | awk '{print $1}'`).
- Nginx / сайт: изменения в порту/имени сервера делаются в `provision/group_vars/instance.yaml` (например `listening_port`, `server_name`), а шаблон конфигурации — `provision/template/default.j2`.

## Контракт (для AI-агента)
- Входы: файлы Terraform/переменные (`terraform.tfvars`, TF_VAR_*), локальный Vault доступ и публичный SSH-ключ в `ssh_key`.
- Выходы: созданные VM (публичные IP попадают в `provision/inventory.ini`), настроенный nginx с index из `provision/template/index.html.j2`.
- Ошибки, которые часто встречаются: отсутствие Vault/неверный role_id/secret_id, недоступность S3-бэкенда, SSH не открылся в ожидаемое время -> `null_resource` зависнет на ожидании.

## Частые правки и где их делать (с примерами)
- Изменить порт nginx -> `provision/group_vars/instance.yaml` (изменить `listening_port`) и при необходимости править `default.j2`.
- Добавить пакеты -> `provision/group_vars/instance.yaml` в список `packages`.
- Отладка Ansible шаблонов -> локально запустить `ansible-playbook` с `-i provision/inventory.ini` после генерации инвентори (`terraform apply` или вручную с `terraform apply -target=local_file.inventory`).

## Ограничения и заметки
- Terraform требует версии >= 1.9.8 (см. `provider.tf`). Комментарии в `provider.tf` указывают на версии Terraform/поведение backend для совместимости.
- Не предполагается CI/CD внутри этого репозитория — провайдер Vault настроен на локальную машину. Если вы мигрируете в CI, убедитесь, что Vault и доступ к backend настроены в окружении CI.

Если что-то неясно или нужно, чтобы я автоматически добавил примеры runbook-команд в `README.md` или включил проверку линтинга Terraform/Ansible — скажите, добавлю. Хотите, чтобы я внес это в `README.md` тоже или достаточно `.github/copilot-instructions.md`?