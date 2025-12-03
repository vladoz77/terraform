**Role: jenkins**
- Путь: `ansible/roles/jenkins`
- Назначение: разворачивает Jenkins в Docker Compose под выбранным пользователем, копирует конфигурационные шаблоны, запускает контейнеры и при необходимости получает API-токен.

**Краткое содержание**
- Управление состоянием: `compose_state` — `present` / `absent`.
- Установка/обновление: копируются шаблоны из `templates/` -> запускается `docker compose` (через `community.docker.docker_compose_v2`).
- Получение API-токена: выполняется curl к Jenkins и результат сохраняется на control node в `default_token_dir`.

**Требования / зависимости**
- Ansible >= 2.10
- Коллекция: `community.docker` (для модулей `docker_compose_v2` и `docker_container_info`).
- На целевой машине: Docker и docker-compose (на платформе используется `community.docker` с V2 API).
- `jq` устанавливается ролью `common` в этом репозитории. Убедитесь, что роль `common` применяется на хосте перед выполнением роли `jenkins`.

**Структура роли**
- `defaults/main.yaml` — значения по умолчанию (имена контейнеров, порты, список плагинов и т.д.).
- `vars/main.yaml` — вспомогательные переменные (`jenkins_docker_dir`, списки файлов).
- `tasks/main.yaml` — основной контрольный плей: проверка наличия docker-compose файла, вызов установки/удаления, генерация API-токена.
- `tasks/jenkins-install.yaml` — копирование шаблонов и запуск compose, проверка доступности Jenkins.
- `tasks/get-api-token.yaml` — получение токена и сохранение на control node.
- `tasks/jenkins-unninstall.yaml` — остановка compose и удаление данных.
- `templates/` — `Dockerfile.j2`, `docker-compose.yaml.j2`, `jenkins.yaml.j2`, `plugins.txt.j2`, `nexus.groovy.j2`.

**Главные переменные (из `defaults/main.yaml` и `vars/main.yaml`)**
- `compose_state` (string) — `present` или `absent`. Default: `present`.
- `jenkins_container_name` (string) — имя контейнера. Default: `jenkins`.
- `jenkins_web_port` (string/int) — порт web интерфейса. Default: `8080`.
- `jenkins_url` (string) — URL (используется для healthcheck и генерации токена). Default: `{{ jenkins_container_name }}.home.local`.
- `jenkins_images` / `jenkins_image_version` — образ Jenkins и тег (по умолчанию `jenkins/jenkins:lts-jdk21`).
- `jenkins_username`, `jenkins_password` — учётные данные для первичного доступа (используются для генерации API-токена).
- `default_token_dir` — путь на control node, в который будет записан API-токен (по умолчанию `/tmp/jenkins-token.txt`).
- `nexus_enabled`, `nexus_username`, `nexus_password` — опции интеграции с Nexus (по умолчанию `false`).
- `jenkins_plugin_list` — список плагинов, который попадает в `plugins.txt`.
- `jenkins_docker_dir` (vars) — каталог на хосте, куда копируются все шаблоны и откуда запускается compose (по умолчанию `/home/{{ ansible_user }}/{{ jenkins_container_name }}`).
- `jenkins_base_files`, `jenkins_nexus_files` — файлы из `templates` которые копируются.

(Полный список — см. `defaults/main.yaml` и `vars/main.yaml`.)

**Поведение**
- Если `compose_state == "present"` роль:
  - проверяет наличие `docker-compose.yaml` в `jenkins_docker_dir` и состояние контейнера;
  - если файла нет или контейнер не запущен/нездоров, копирует шаблоны и запускает `docker compose`;
  - ждёт доступности `/login` (https) и затем пытается сгенерировать API-токен;
  - записывает токен на control node в `default_token_dir` (делегируется `localhost`).

- Если `compose_state == "absent"` роль:
  - вызывает `docker compose down` (удаляет тома) и удаляет папку с данными;
  - удаляет локальный файл с токеном на control node.

**Пример использования (playbook)**
```yaml
- name: Deploy Jenkins
  hosts: jenkins
  become: true
  vars:
    compose_state: present
    jenkins_url: jenkins.example.local
    jenkins_username: admin
    jenkins_password: "supersecret"   # лучше хранить в vault
    nexus_enabled: false
    jenkins_docker_dir: "/home/{{ ansible_user }}/jenkins"
  roles:
    - role: jenkins
```

Если вы хотите управляеть установкой через group_vars/host_vars, поместите соответствующие переменные туда:
- `group_vars/jenkins.yaml` — `jenkins_url`, `jenkins_password`, `nexus_enabled` и т.д.

**Где сохраняется API-токен**
- Результат генерации токена записывается на control node в файл `default_token_dir` (по умолчанию `/tmp/jenkins-token.txt`). Права файла устанавливаются `0600`.

**Шаблоны**
- `docker-compose.yaml.j2` — содержит сервисы Jenkins и зависимости (Traefik/внешняя сеть не включены внутри роли — проверьте шаблон).
- `jenkins.yaml.j2` — файл конфигурации для Jenkins (например `provisioning` или `casc`).
- `plugins.txt.j2` — список плагинов, формируемый из `jenkins_plugin_list`.
- `nexus.groovy.j2` — groovy-скрипт для интеграции с Nexus (копируется только если `nexus_enabled: true`).

**Рекомендации и примечания**
- Не храните `jenkins_password` в плейбуке в открытом виде — используйте Ansible Vault или хранилище секретов.
- Убедитесь, что на целевом хосте установлены Docker и возможности запуска compose через `community.docker`.
- Скрипт генерации API-токена использует `jq`. В этом проекте `jq` устанавливается ролью `common`; если вы выполняете роль в другой среде — убедитесь, что `jq` доступен, либо модифицируйте задачу для парсинга без `jq`.
- Если Jenkins доступен по HTTPS с самоподписанным сертификатом, роль использует `validate_certs: no` при healthcheck и токене — при возможности настройте CA и включите проверку сертификата.

**Отладка**
- Логи Ansible покажут шаг, на котором роль упала. Частые места ошибок:
  - отсутствие Docker/dockerd или прав запуска.
  - ошибки шаблонов (проверьте `templates/` и переменные).
  - curl/jq не возвращают ожидаемый JSON при получении токена — проверьте `jenkins_username`/`jenkins_password`.

**Контрибьютинг / улучшения**
- Можно добавить проверку наличия `jq` и автоматическую установку (через пакетный менеджер) при отсутствии.
- Добавить опцию для записи токена в секретный стор вместо файла на control node.


