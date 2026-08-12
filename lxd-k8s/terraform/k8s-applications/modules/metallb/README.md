# metallb

Terraform-модуль для установки MetalLB в Kubernetes через Helm и создания `IPAddressPool` и `L2Advertisement`.

## Что создает модуль

- `helm_release.metallb`
- `kubectl_manifest.ippool`
- `kubectl_manifest.l2advertisements`

## Требования

- Terraform `>= 1.9.0`
- `hashicorp/helm >= 3.0.0`
- `gavinbunney/kubectl >= 1.7.0`
- доступ к Kubernetes-кластеру через настроенные провайдеры

## Использование

```hcl
module "metallb" {
  source = "./modules/metallb"

  name             = "metallb"
  namespace        = "metallb-system"
  chart_version    = "0.16.0"
  create_namespace = true

  ippools = {
    "system-pool"     = ["172.18.255.200-172.18.255.250"]
    "production-pool" = ["10.0.1.0/24"]
  }
}
```

## Входные параметры

| Имя | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `kube_config_path` | `string` | `~/.kube/config` | Объявлен в модуле, но напрямую в ресурсах не используется. Провайдеры обычно передаются снаружи. |
| `name` | `string` | `metallb` | Имя Helm release. |
| `namespace` | `string` | `metallb-system` | Namespace для установки MetalLB. |
| `chart_version` | `string` | `0.16.0` | Версия Helm chart `metallb`. |
| `create_namespace` | `bool` | `true` | Создать namespace автоматически перед установкой chart. |
| `ippools` | `map(list(string))` | `{"default-pool" = ["10.0.0.0/24"]}` | Пулы адресов для ресурсов `IPAddressPool`. Для каждого пула также создается `L2Advertisement`. |

## Как это работает

1. Устанавливается chart `metallb` из репозитория `https://metallb.github.io/metallb`.
2. Для каждого элемента из `ippools` создается `IPAddressPool`.
3. После этого для каждого пула создается отдельный `L2Advertisement`, ссылающийся на соответствующий `IPAddressPool`.

## Особенности

- Все `IPAddressPool` и `L2Advertisement` создаются в том же namespace, что и MetalLB.
- Модуль не объявляет `output`-переменные.
- Значение `kube_config_path` есть в переменных модуля, но внутри ресурсов не используется напрямую.
