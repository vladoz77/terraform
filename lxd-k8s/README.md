# LXD Kubernetes Cluster

Этот репозиторий разворачивает Kubernetes-кластер в LXD и доводит его до рабочего состояния в три шага:

1. `terraform/infrastucture` создает LXD-сеть, storage pools, виртуальные машины и Ansible inventory.
2. `ansible` подготавливает ноды и устанавливает Kubernetes.
3. `terraform/k8s-applications` ставит базовые приложения в кластер через Helm и `kubectl`.

## Что есть в репозитории

- `terraform/infrastucture` - слой инфраструктуры LXD.
- `terraform/modules/lxd_network` - модуль сети LXD bridge.
- `terraform/modules/lxd_instance` - модуль создания VM/instances.
- `terraform/k8s-applications` - базовые Kubernetes-приложения.
- `ansible` - плейбуки и роли для установки и расширения кластера.

## Поддерживаемые окружения

Проект уже разложен по окружениям:

- Terraform vars: `terraform/infrastucture/environment/dev-terraform.tfvars`, `stage-terraform.tfvars`, `prod-terraform.tfvars`
- Ansible inventory: `ansible/inventories/dev`, `stage`, `prod`

Имя окружения задается через переменную `environment`. На ее основе Terraform генерирует inventory в файл:

`ansible/inventories/<environment>/inventory.ini`

## Как устроен workflow

### 1. Infrastructure

Слой `terraform/infrastucture`:

- создает `lxd_profile`
- создает storage pools из `var.pools`
- поднимает bridge-сеть `lxdbr0`
- создает master/worker инстансы из `var.instances`
- генерирует inventory для Ansible

Инстансы с именами, начинающимися на `master`, автоматически попадают в группу `master`, а `worker` - в группу `worker`.

### 2. Kubernetes bootstrap

Основной плейбук: `ansible/k8s-install-all.yaml`

Он:

- применяет базовую конфигурацию ко всем нодам
- подготавливает control plane
- при `ha_enabled: true` настраивает HA для master-нод
- подключает worker-узлы к кластеру

Дополнительно есть:

- `ansible/k8s-master-install.yaml` - настройка только master-нод
- `ansible/k8s-add-worker.yaml` - добавление новых worker-нод

Основные параметры кластера лежат в `ansible/inventories/<environment>/group_vars/all.yaml`.

### 3. Kubernetes applications

Слой `terraform/k8s-applications` использует существующий kubeconfig и ставит:

- MetalLB
- Envoy Gateway
- cert-manager
- metrics-server
- local-path-provisioner

Также слой читает remote state инфраструктуры через `terraform_remote_state`.

## Требования

- LXD должен быть установлен и доступен по API
- Terraform `>= 1.9.0`
- Ansible и нужные коллекции
- kubeconfig для доступа к созданному кластеру
- доступ к S3-compatible backend, который указан в Terraform backend

Если используется текущая конфигурация backend, нужны ключи для Yandex Object Storage.

## Быстрый старт

### 1. Развернуть инфраструктуру

```bash
cd terraform/infrastucture
terraform init \
  -backend-config="access_key=..." \
  -backend-config="secret_key=..."
terraform plan -var-file=environment/dev-terraform.tfvars
terraform apply -var-file=environment/dev-terraform.tfvars
```

После `apply` inventory появится в `ansible/inventories/dev/inventory.ini`.

### 2. Установить Kubernetes через Ansible

```bash
cd ../../ansible
ansible-galaxy collection install -r requirements.yaml
ansible-playbook \
  -i inventories/dev/inventory.ini \
  --user vlad \
  --ssh-extra-args "-o StrictHostKeyChecking=no" \
  k8s-install-all.yaml
```

### 3. Установить базовые приложения в кластер

```bash
cd ../terraform/k8s-applications
terraform init \
  -backend-config="access_key=..." \
  -backend-config="secret_key=..."
terraform plan
terraform apply
```

По умолчанию используется `~/.kube/config`. При необходимости путь можно переопределить через `kube_config_path`.

## Что обычно меняют

- `terraform/infrastucture/environment/*.tfvars` - состав нод, IP-адреса, storage pools, образ LXD
- `terraform/infrastucture/cloud-init.yaml` - начальная настройка VM
- `ansible/inventories/*/group_vars/all.yaml` - версия Kubernetes, сеть, HA, kube-proxy mode, Calico и системные пакеты
- `terraform/k8s-applications/variables.tf` - пул адресов MetalLB, параметры CA и путь к kubeconfig


