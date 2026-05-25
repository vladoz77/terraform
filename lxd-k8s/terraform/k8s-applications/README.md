# k8s-applications

Terraform-модуль для развертывания Kubernetes-приложений в homelab-кластере. В текущем состоянии корневой модуль управляет установкой MetalLB через вложенный модуль `modules/metallb`.

## Что делает модуль

- устанавливает Helm chart `metallb` в Kubernetes-кластер;
- создает `IPAddressPool` для каждого пула из переменной `ippools`;
- создает `L2Advertisement` для каждого созданного пула;
- использует удаленный `s3` backend в Yandex Object Storage;
- читает удаленное состояние `lxd/k8s-infrastucture.tfstate`.

## Структура

```text
.
├── main.tf                  # подключение вложенного модуля MetalLB
├── provider.tf              # backend, providers, remote state
├── variables.tf             # переменные корневого модуля
└── modules/
    └── metallb/
        ├── main.tf          # helm_release + Kubernetes manifests
        ├── provider.tf      # requirements провайдеров
        └── variables.tf     # переменные вложенного модуля
```

## Требования

- Terraform `>= 1.9.0`
- доступ к Kubernetes-кластеру через `kubeconfig`
- настроенные credentials для `s3` backend

Используемые провайдеры:

- `hashicorp/helm >= 3.0.0`
- `gavinbunney/kubectl >= 1.7.0`

## Использование

Инициализация и применение выполняются из каталога модуля:

```bash
terraform init
terraform plan
terraform apply
```

Текущая конфигурация MetalLB в корневом модуле выглядит так:

```hcl
module "metallb" {
  source = "./modules/metallb"

  name             = "metallb"
  namespace        = "metallb-system"
  chart_version    = "0.15.3"
  create_namespace = true
  ippools = {
    "system-pool"     = ["172.18.255.200-172.18.255.250"]
    "production-pool" = ["10.0.1.0/24"]
  }
}
```

## Входные параметры корневого модуля

| Имя | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `kube_config_path` | `string` | `~/.kube/config` | Путь к `kubeconfig` для провайдеров `helm`, `kubectl` и `kubernetes`. |
| `ca_subject` | `object` | см. `variables.tf` | Зарезервированная переменная для параметров CA-сертификата. В текущих активных ресурсах не используется. |
| `ca_issuer` | `object` | см. `variables.tf` | Зарезервированная переменная для конфигурации CA issuer. В текущих активных ресурсах не используется. |

## Вложенный модуль `modules/metallb`

### Что создает

- `helm_release.metallb`
- `kubectl_manifest.ippool`
- `kubectl_manifest.l2advertisements`

### Входные параметры

| Имя | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `kube_config_path` | `string` | `~/.kube/config` | Объявлен в модуле, но напрямую в ресурсах не используется. Провайдеры ожидаются снаружи. |
| `name` | `string` | `metallb` | Имя Helm release. |
| `namespace` | `string` | `metallb-system` | Namespace для MetalLB. |
| `chart_version` | `string` | `0.16.0` | Версия Helm chart MetalLB. |
| `create_namespace` | `bool` | `true` | Нужно ли создать namespace автоматически. |
| `ippools` | `map(list(string))` | `{"default-pool" = ["10.0.0.0/24"]}` | Список IP-пулов для создания `IPAddressPool` и `L2Advertisement`. |

### Пример использования как самостоятельного модуля

```hcl
module "metallb" {
  source = "./modules/metallb"

  name             = "metallb"
  namespace        = "metallb-system"
  chart_version    = "0.16.0"
  create_namespace = true

  ippools = {
    "default-pool" = ["10.0.0.0/24"]
    "dmz-pool"     = ["172.18.255.200-172.18.255.250"]
  }
}
```

## Особенности

- Корневой модуль не объявляет `output`-переменные.
- В `provider.tf` подключается `terraform_remote_state.infrastucture`, но в текущих активных ресурсах он напрямую не используется.
- В каталоге `old/` лежат прежние конфигурации `cert-manager`, `envoy-gateway`, `metrics-server` и других компонентов; они не участвуют в текущем применении.
