# 🛠 Ansible Role: `traefik`

Устанавливает и настраивает **Traefik v3.5** как современный reverse-proxy и edge router для Docker-среды.  
Роль обеспечивает автоматическое получение SSL-сертификатов через Let's Encrypt, защищённый доступ к дашборду и корректную работу в production-окружении.

> ✅ Идеально подходит для Jenkins, Nexus и других сервисов, разворачиваемых через Docker.

---

## 🔍 Описание

Эта роль:
- Автоматически освобождает порты `80` и `443`, останавливая конфликтующие контейнеры
- Создаёт и управляет Docker-сетью
- Разворачивает Traefik через `docker-compose`
- Включает дашборд с защитой через Basic Auth
- Настраивает получение сертификатов Let's Encrypt
- Полностью идемпотентна и готова к использованию в CI/CD

---

## 🧩 Структура роли

```
roles/traefik/
├── defaults/
│   └── main.yaml          # переменные по умолчанию
├── meta/
│   └── main.yaml          # зависимости
├── tasks/
│   ├── install.yaml       # установка и настройка
│   └── main.yaml          # проверка и запуск
└── templates/
    └── docker-compose-traefik.yaml.j2  # шаблон compose
```

---

## ⚙️ Переменные по умолчанию

Файл: `defaults/main.yaml`

```yaml
# Docker config
docker_network_name: "bridge"                             # Сеть для Traefik
traefik_container_name: "traefik"                         # Имя контейнера
traefik_image: "traefik"                                  # Образ
traefik_version: "v3.5"                                   # Версия
traefik_docker_dir: "/home/{{ ansible_user }}/{{ traefik_container_name }}"  # Путь к compose
traefik_letsencrypt_path: "{{ traefik_docker_dir }}/letsencrypt"             # Хранение сертификатов

# Dashboard config
traefik_enable_dashboard: true                            # Включить дашборд
traefik_dashboard_url: "{{ traefik_container_name }}.{{ domain_name }}"  # URL дашборда
traefik_dashboard_user: "admin"                           # Логин
traefik_dashboard_password_hash: "$$apr1$$CmiVRFjs$$bPQcSgQ.2HcTzM.HVTvAl1"  # Пароль: admin

# ACME / Let's Encrypt
domain_name: "yc.home-local.site"                         # Базовый домен
acme_email: "vladoz77@yandex.ru"                          # Email для Let's Encrypt
```

---

## 🔐 Рекомендации по безопасности

| Что | Рекомендация |
|-----|--------------|
| Пароль в открытом виде | Сгенерируй свой: `htpasswd -nBC 10 admin` |
| `bridge` сеть | Замени на `traefik-network` (см. ниже) |
| `acme_email` | Вынеси в `group_vars` или Ansible Vault |
| `insecure: true` | Убери после настройки, если не нужен API |

---

## 🚀 Использование

### В плейбуке

```yaml
- hosts: jenkins-server
  become: yes
  roles:
    - role: traefik
      traefik_container_name: "traefik"
      domain_name: "yc.home-local.site"
```

### С переопределением переменных

```yaml
- name: Deploy Traefik
  ansible.builtin.include_role:
    name: traefik
  vars:
    traefik_container_name: "traefik-prod"
    acme_email: "admin@company.com"
    traefik_enable_dashboard: false
```

---

## 🔄 Как работает роль

1. **Проверяет**, запущен ли контейнер `traefik`
2. **Останавливает и удаляет** любые контейнеры, занимающие порты `80` и `443`
3. **Создаёт сеть**, если не существует
4. **Создаёт директорию** и копирует `docker-compose.yaml`
5. **Запускает Traefik** через `docker compose up`

> ✅ Гарантирует чистый запуск даже при смене имени или конфигурации.

---

## 🛠 Зависимости

- Установленный Docker (через роль `docker`)
- Коллекция: `community.docker`

```bash
ansible-galaxy collection install community.docker
```

Роль зависит от `docker`:

```yaml
# meta/main.yaml
dependencies:
  - role: docker
```

---

## 🌍 Доступные URL

| URL | Описание |
|-----|--------|
| `https://traefik.yc.home-local.site` | Дашборд Traefik (если включён) |
| `http://<ваш_хост>` | Автоматическое перенаправление на HTTPS |
| `https://<ваш_сервис>.yc.home-local.site` | Сервисы, подключённые к той же сети и с лейблами Traefik |

---

## ✅ Проверка после установки

```bash
# Проверь, что контейнер запущен
docker ps --filter name=traefik

# Проверь, что порты открыты
ss -tulnp | grep ':80\|:443'

# Проверь логи
docker logs traefik
```
