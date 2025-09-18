# 🛠 Ansible Role: `nexus`

Роль для автоматического развёртывания и настройки **Sonatype Nexus Repository Manager 3** с интеграцией в Traefik, созданием пользователей, ролей и Docker-репозиториев.

> ✅ Подходит для CI/CD, хранения Docker-образов, Maven-артефактов и других бинарных ресурсов.

---

## ✅ Особенности

- 🚀 Автоматическое развёртывание Nexus через Docker и `docker-compose`
- 🔐 Смена пароля администратора при первом запуске
- 👤 Создание пользователей с кастомными ролями
- 📦 Настройка Docker-репозитория с публичным доступом через Traefik
- 🌐 Поддержка HTTPS через Let's Encrypt (через Traefik)
- 🔁 Идемпотентность: не пересоздаёт контейнер, если он уже работает
- 🔄 Полная настройка через REST API после запуска

---

## 🧩 Структура роли

```
roles/nexus/
├── defaults/
│   └── main.yaml          # переменные по умолчанию
├── tasks/
│   ├── main.yaml          # основная логика
│   ├── nexus-install.yaml # установка через docker-compose
│   └── nexus-config.yaml  # настройка через REST API
├── templates/
│   └── docker-compose-nexus.yaml.j2  # шаблон compose
└── vars/
    └── main.yaml          # внутренние пути и endpoint'ы API
```

---

## ⚙️ Переменные по умолчанию

Файл: `defaults/main.yaml`

```yaml
# Docker config
nexus_container_name: "nexus"
nexus_image: "sonatype/nexus3"
nexus_image_version: "3.82.1"
nexus_docker_dir: "/home/{{ username }}/{{ nexus_container_name }}"
nexus_web_port: "8081"
nexus_domain_name: "{{ nexus_container_name }}.{{ domain_name | default('home.local') }}"

# Nexus user config
new_admin_password: "Qwerty123"
nexus_username: "jenkins"
nexus_password: "!QAZ2wsx"
role_id: "docker-role"

# Repository config
repo_name: "docker-hosted"
repo_port: "8082"
registry_name: "{{ repo_name }}"
registry_domain_name: "{{ registry_name }}.{{ domain_name | default('home.local') }}"
```

> 🔐 Для production замените пароли и используйте Ansible Vault.

---

## 🔐 Рекомендации по безопасности

| Что | Рекомендация |
|-----|--------------|
| Пароли в открытом виде | Переместите в `group_vars` и зашифруйте через `ansible-vault` |
| `admin` пользователь | После настройки отключите или ограничьте |
| `domain_name` | Укажите реальный домен, например: `yc.home-local.site` |

---

## 🚀 Использование

### 1. Включить роль в плейбук

```yaml
- hosts: jenkins-server
  become: yes
  roles:
    - role: nexus
      domain_name: "yc.home-local.site"
      username: "ubuntu"
```

### 2. Или с переопределением переменных

```yaml
- name: Deploy Nexus
  ansible.builtin.include_role:
    name: nexus
  vars:
    nexus_container_name: "nexus-prod"
    new_admin_password: "{{ vault_nexus_admin_pass }}"
    domain_name: "mycompany.com"
```

---

## 🔄 Как работает роль

### Этап 1: Установка

1. Проверяет, запущен ли контейнер `nexus`
2. Создаёт директорию и `docker-compose.yaml`
3. Запускает Nexus через `docker compose up`

### Этап 2: Настройка (через REST API)

1. Ждёт, пока Nexus станет доступен
2. Меняет пароль `admin` (если это первый запуск)
3. Создаёт роль `docker-role` с правами на Docker-репозитории
4. Создаёт пользователя `jenkins` с этой ролью
5. Создаёт hosted Docker-репозиторий `docker-hosted` на порту `8082`

---

## 🌐 Доступные URL

| URL | Назначение |
|-----|-----------|
| `https://nexus.yc.home-local.site` | Веб-интерфейс Nexus |
| `https://docker-hosted.yc.home-local.site` | Docker Registry (push/pull) |
| `http://localhost:8081` | Локальный доступ к Nexus |

---

## 🐳 Docker Compose (шаблон)

Роль генерирует `docker-compose.yaml` с:
- Пробросом портов `8081` и `8082`
- Подключением к сети `traefik`
- Настройкой Traefik для двух доменов:
  - `nexus.*` → веб-интерфейс (порт 8081)
  - `docker-hosted.*` → Docker registry (порт 8082)

> ✅ Поддерживает Let's Encrypt через `le` certresolver.

---

## 🔧 Зависимости

- Установленный Docker (роль `docker`)
- Сеть `traefik` должна существовать
- Traefik должен быть запущен и настроен
- Коллекция: `community.docker`

```bash
ansible-galaxy collection install community.docker
```

---

## ✅ Проверка после установки

```bash
# Проверь, что контейнер запущен
docker ps --filter name=nexus

# Проверь логи
docker logs nexus

# Проверь, что репозиторий создан
curl -u jenkins:!QAZ2wsx https://nexus.yc.home-local.site/service/rest/v1/repositories

# Проверь доступ к Docker registry
docker login docker-hosted.yc.home-local.site
```

---

## 🛠 API Endpoints (внутренние)

Файл: `vars/main.yaml` — содержит пути к REST API Nexus:

```yaml
nexus_url: http://localhost:8081
get_role: service/rest/v1/security/roles
create_role: service/rest/v1/security/roles
status_check: service/rest/v1/status
change_password: service/rest/v1/security/users/admin/change-password
get_user: service/rest/v1/security/users
create_user: service/rest/v1/security/users
get_repo: service/rest/v1/repositories/docker/hosted
create_repo_hosted: service/rest/v1/repositories/docker/hosted
```

