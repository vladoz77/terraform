# gateway

Terraform-модуль для установки Envoy Gateway через Helm и создания ресурсов `GatewayClass`, `EnvoyProxy` и `Gateway`.

## Что создает модуль

- `helm_release.gateway_controller`
- `kubectl_manifest.envoy_gatewayclass`
- `kubectl_manifest.envoy_proxy`
- `kubectl_manifest.gateway`
- `output.gateway_info`

## Требования

- Terraform `>= 1.9.0`
- `hashicorp/helm >= 3.0.0`
- `gavinbunney/kubectl >= 1.7.0`
- доступ к Kubernetes-кластеру через настроенные провайдеры

## Использование

```hcl
module "gateway" {
  source = "./modules/gateway"

  namespace     = "envoy-gateway-system"
  gateway_class = "envoy-gateway-class"

  gateway_controller = {
    name             = "envoy-gateway"
    chart_name       = "gateway-helm"
    version          = "v1.7.0"
    repository       = "oci://docker.io/envoyproxy"
    create_namespace = true
    cleanup_on_fail  = true
  }

  gateway = {
    "system-gateway" = {
      class_name     = "envoy-gateway-class"
      namespace      = "envoy-gateway-system"
      address_pool   = "system-pool"
      listeners = [
        {
          name      = "http"
          port      = 80
          protocol  = "HTTP"
          hostnames = ["*.dev.local"]
          allowed_routes = {
            namespaces_from = "All"
          }
        }
      ]
    }

    "public-gateway" = {
      class_name     = "envoy-gateway-class"
      namespace      = "default"
      address_pool   = "production-pool"
      cluster_issuer = "letsencrypt-prod"
      listeners = [
        {
          name      = "https"
          port      = 443
          protocol  = "HTTPS"
          hostnames = ["app.example.com"]
        }
      ]
    }
  }
}
```

## Входные параметры

| Имя | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `namespace` | `string` | `envoy-gateway-system` | Namespace для установки Helm release Envoy Gateway. |
| `gateway_class` | `string` | `envoy-gateway-class` | Имя создаваемого `GatewayClass`. |
| `gateway_controller` | `object` | См. `variables.tf` | Конфигурация Helm release для контроллера Envoy Gateway. |
| `gateway` | `map(object(...))` | См. `variables.tf` | Набор gateway-ресурсов и их listeners. |

## Поля `gateway`

| Поле | Тип | Описание |
| --- | --- | --- |
| `class_name` | `string` | Имя класса gateway в описании объекта. Сейчас модуль всегда использует `var.gateway_class` при создании ресурса `Gateway`. |
| `namespace` | `string` | Namespace для `Gateway` и связанного `EnvoyProxy`. |
| `cluster_issuer` | `string` | ClusterIssuer для cert-manager. Используется только если среди listeners есть `HTTPS`. |
| `address_pool` | `string` | Имя пула MetalLB для аннотации `metallb.universe.tf/address-pool`. В типе переменной поле помечено как optional, но фактически модуль ожидает, что оно будет задано. |
| `listeners` | `list(object)` | Список listeners для `Gateway`. |

## Поля `listeners`

| Поле | Тип | По умолчанию | Описание |
| --- | --- | --- | --- |
| `name` | `string` | - | Имя listener. |
| `port` | `number` | - | Порт listener. |
| `protocol` | `string` | - | Протокол listener, например `HTTP` или `HTTPS`. |
| `hostnames` | `list(string)` | `[]` | Список hostname-ов. |
| `allowed_routes` | `object` | `null` | Настройки `allowedRoutes.namespaces.from`. |

## Output

| Имя | Описание |
| --- | --- |
| `gateway_info` | Карта gateway-объектов в упрощенном виде: имя, `class_name`, `namespace` и список listeners с `port` и `protocol`. |

## Как работает модуль

1. Устанавливает Envoy Gateway controller через Helm.
2. Создает один `GatewayClass`.
3. Для каждого элемента `gateway` создает `EnvoyProxy` с именем `"<address_pool>-proxy"`.
4. Затем создает `Gateway`, который ссылается на соответствующий `EnvoyProxy`.
5. Если у gateway есть хотя бы один listener с `protocol = "HTTPS"`, модуль добавляет аннотацию `cert-manager.io/cluster-issuer` и настраивает `tls.certificateRefs` на secret `"<gateway-name>-tls-secret"`.

## Особенности

- Если у нескольких gateway одинаковый `address_pool`, они приведут к созданию одного и того же имени `EnvoyProxy`.
- Для `HTTPS` listener модуль ожидает, что будет использоваться secret с именем `"<gateway-name>-tls-secret"`.
- Поле `class_name` есть во входных данных и в output, но при создании ресурса `Gateway` не влияет на `gatewayClassName`: используется `var.gateway_class`.
- В `default`-примере переменной `gateway` не указан `address_pool`, хотя в рабочей конфигурации он нужен.
