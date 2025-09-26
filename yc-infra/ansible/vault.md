# 🛡️ Использование HashiCorp Vault как хранилища секретов в Ansible

> **Цель**: Научиться безопасно хранить и использовать чувствительные данные (логины, пароли, токены и т.д.) в Ansible-плейбуках, извлекая их из HashiCorp Vault с использованием механизма аутентификации **AppRole**.

---

## 🔧 Часть 1. Подготовка HashiCorp Vault

### 1.1. Включение секретного движка KV (Key-Value)

HashiCorp Vault поддерживает несколько типов секретных движков. Для хранения статических секретов (например, учётных данных) используется **KV (Key-Value)**, версии 2 рекомендуется по умолчанию.

```bash
vault secrets enable -path=ansible kv-v2
```

- `-path=ansible` — путь, по которому будут храниться секреты. Вы можете выбрать любое имя (например, `secrets/ansible`), но оно должно быть последовательным.
- `kv-v2` — вторая версия KV-движка, поддерживающая версионирование секретов и метаданные.

> 💡 **Примечание**: Убедитесь, что Vault запущен и вы аутентифицированы (например, через `vault login`).

---

### 1.2. Запись секрета

Создадим секрет с учётными данными для Nexus:

```bash
vault kv put ansible/nexus nexus_username=jenkins nexus_password=password
```

- `ansible/nexus` — путь к секрету внутри движка KV.
- `nexus_username`, `nexus_password` — ключи и значения секрета.

> 🔒 **Рекомендация**: Никогда не используйте реальные пароли в примерах. В продакшене используйте надёжные, генерируемые пароли или временные токены.

Проверка содержимого:

```bash
vault kv get ansible/nexus
```

Ожидаемый вывод:

```
========= Data =========
Key               Value
---               -----
nexus_password    password
nexus_username    jenkins
```

---

### 1.3. Создание политики доступа

Для безопасного доступа к секретам создаётся **политика**, ограничивающая права только на чтение нужных путей.

```bash
vault policy write ansible-policy - <<EOF
path "ansible/*" {
  capabilities = ["read"]
}
EOF
```

- Политика `ansible-policy` разрешает **только чтение** (`read`) по любому пути внутри `ansible/`.
- Это соответствует принципу **минимальных привилегий**.

Проверить политику можно командой:

```bash
vault policy read ansible-policy
```

---

### 1.4. Настройка AppRole-аутентификации

AppRole — это механизм аутентификации, предназначенный для машин и автоматизированных систем (в отличие от пользовательских методов, таких как LDAP или GitHub).

#### Включаем AppRole:

```bash
vault auth enable approle
```

#### Создаём роль для Ansible:

```bash
vault write auth/approle/role/ansible-role \
  policies="ansible-policy" \
  token_ttl="1h" \
  token_max_ttl="4h"
```

- `policies="ansible-policy"` — привязывает роль к созданной политике.
- `token_ttl` — время жизни выданного токена (1 час).
- `token_max_ttl` — максимальное время жизни токена (4 часа), даже при обновлении.

> ⚠️ **Важно**: Не используйте `token_type=batch` в продакшене, если вам не нужна высокая производительность без возможности отзыва токена. По умолчанию используется `service`-токены, которые можно отозвать.

Проверка роли:

```bash
vault read auth/approle/role/ansible-role
```

---

### 1.5. Получение учётных данных роли (Role ID и Secret ID)

AppRole использует два идентификатора:

- **Role ID** — публичный идентификатор роли (аналог логина).
- **Secret ID** — секретный ключ (аналог пароля), который можно генерировать многократно.

#### Получаем Role ID:

```bash
vault read auth/approle/role/ansible-role/role-id
```

Пример вывода:

```
Key        Value
---        -----
role_id    95b272fa-e628-a4f2-74b1-2c9713bab027
```

#### Генерируем Secret ID:

```bash
vault write -f auth/approle/role/ansible-role/secret-id
```

Пример вывода:

```
Key                   Value
---                   -----
secret_id             e3f2e2ad-9036-406d-5da2-234947d40c8f
secret_id_accessor    e2c4991f-c88e-f2ed-b2ef-171b1054ba58
```

> 🔐 **Безопасность**: Secret ID должен храниться в защищённом месте (например, в CI/CD-переменных, HashiCorp Vault itself, или менеджере секретов). Никогда не коммитьте его в Git!

---

## 🤖 Часть 2. Настройка Ansible для работы с Vault

### 2.1. Установка зависимостей

Ansible использует Python-библиотеку `hvac` для взаимодействия с Vault, а также специальную коллекцию от сообщества.

#### Установка `hvac`:

```bash
pip3 install hvac
```

> Убедитесь, что используется та же версия Python, что и в вашем окружении Ansible.

#### Установка коллекции `community.hashi_vault`:

```bash
ansible-galaxy collection install community.hashi_vault
```

Эта коллекция предоставляет **lookup-плагин** `hashi_vault`, который позволяет извлекать секреты прямо в плейбуках.

---

### 2.2. Передача учётных данных в Ansible

Существует несколько способов передать `role_id` и `secret_id` в Ansible. Наиболее безопасный — через **переменные окружения** или **Ansible Vault**.

#### Вариант: через переменные окружения

```bash
export VAULT_ROLE_ID=95b272fa-e628-a4f2-74b1-2c9713bab027
export VAULT_SECRET_ID=e3f2e2ad-9036-406d-5da2-234947d40c8f
```

> 💡 **Альтернатива**: Используйте `.env`-файл с `source .env` или передавайте через CI/CD (GitHub Actions, GitLab CI и т.д.).

---

### 2.3. Пример плейбука с извлечением секретов

```yaml
---
- name: Configure Nexus server using secrets from HashiCorp Vault
  hosts: nexus-server
  become: true
  vars:
    # URL вашего Vault-сервера
    vault_url: "http://localhost:8200"

    # Получаем Role ID и Secret ID из переменных окружения
    role_id: "{{ lookup('env', 'VAULT_ROLE_ID') }}"
    secret_id: "{{ lookup('env', 'VAULT_SECRET_ID') }}"

    # Извлекаем секрет из Vault
    nexus_secret: >-
      {{
        lookup(
          'community.hashi_vault.hashi_vault',
          'secret=ansible/nexus',
          'auth_method=approle',
          'role_id=' + role_id,
          'secret_id=' + secret_id,
          'url=' + vault_url
        )
      }}

    # Распаковываем значения
    nexus_username: "{{ nexus_secret.nexus_username }}"
    nexus_password: "{{ nexus_secret.nexus_password }}"

  tasks:
    - name: Display Nexus credentials (for demo only!)
      debug:
        msg: "Username: {{ nexus_username }}, Password: {{ nexus_password }}"

    # Пример: создание файла с учётными данными
    - name: Create Nexus auth file
      copy:
        content: |
          username={{ nexus_username }}
          password={{ nexus_password }}
        dest: /etc/nexus/auth.conf
        mode: '0600'
```

> ⚠️ **Важно**: Никогда не выводите секреты в логи (`debug`, `stdout`) в продакшене! Пример выше — только для демонстрации.

---

## 🔐 Рекомендации по безопасности

1. **Не храните секреты в репозитории** — ни `role_id`, ни `secret_id`, ни пароли.
2. **Используйте временные Secret ID** с ограниченным количеством использований:
   ```bash
   vault write auth/approle/role/ansible-role/secret-id \
     secret_id_num_uses=10 \
     secret_id_ttl=2h
   ```
3. **Ограничьте CIDR-диапазоны**, с которых можно аутентифицироваться:
   ```bash
   vault write auth/approle/role/ansible-role \
     policies="ansible-policy" \
     token_ttl="1h" \
     token_max_ttl="4h" \
     secret_id_bound_cidrs="10.0.0.0/24"
   ```
4. **Мониторьте аудит-логи Vault** — включите аудит (`vault audit enable file ...`), чтобы отслеживать доступ к секретам.
5. **Регулярно ротируйте Secret ID** — особенно в случае компрометации.

---

## 🔄 Альтернативные методы аутентификации

Хотя AppRole — стандарт для машин, вы также можете использовать:

- **Token** — если у вас уже есть долгоживущий токен (менее безопасно).
- **Kubernetes Auth** — если Ansible запускается внутри Kubernetes.
- **AWS/GCP Auth** — если инфраструктура размещена в облаке.

Пример с токеном:

```yaml
nexus_secret: "{{ lookup('community.hashi_vault.hashi_vault', 'secret=ansible/nexus auth_method=token token=my-vault-token url=http://vault:8200') }}"
```

---

## ✅ Заключение

Интеграция HashiCorp Vault с Ansible позволяет:

- Централизованно управлять секретами.
- Избегать хранения чувствительных данных в коде.
- Гибко настраивать права доступа.
- Соответствовать требованиям безопасности и аудита.

Следуя этой инструкции, вы сможете безопасно и эффективно использовать Vault в своих автоматизациях.

---

> 📚 **Дополнительные ресурсы**:
> - [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs)
> - [Ansible HashiCorp Vault Lookup Plugin](https://docs.ansible.com/ansible/latest/collections/community/hashi_vault/hashi_vault_lookup.html)
> - [AppRole Auth Method Guide](https://developer.hashicorp.com/vault/docs/auth/approle)
