# Terraform Kubernetes Stack Deployment

Этот репозиторий содержит Terraform-конфигурации для развертывания базового стека Kubernetes, включая Ingress Controller, Cert-Manager и Argo CD.

## Компоненты инфраструктуры

1. **Ingress-Nginx** - Входная точка для трафика в кластер
2. **Cert-Manager** - Управление TLS-сертификатами (Let's Encrypt)
3. **Argo CD** - GitOps-инструмент для непрерывного развертывания

## Предварительные требования

- Terraform >= 1.0
- kubectl
- Helm
- Доступ к Kubernetes кластеру
- Настроенный kubeconfig (`~/.kube/config` по умолчанию)
- S3-совместимое хранилище для Terraform state (Yandex Cloud Object Storage в данном случае)

## Структура файлов

```
.
├── provider.tf        - Конфигурация провайдеров и бэкенда
├── variables.tf       - Переменные Terraform
├── ingress.tf         - Развертывание Ingress-Nginx
├── certmanager.tf     - Установка Cert-Manager и ClusterIssuer
├── argocd.tf          - Развертывание Argo CD
├── ingress/           - Каталог с шаблонами Ingress
│   └── values.yaml.tpl
└── argocd/            - Каталог с конфигурацией Argo CD
    └── values.yaml
```

## Использование

1. Инициализация Terraform:
   ```bash
   terraform init
   ```

2. Просмотр плана изменений:
   ```bash
   terraform plan
   ```

3. Применение изменений:
   ```bash
   terraform apply
   ```

4. Для удаления всех ресурсов:
   ```bash
   terraform destroy
   ```

## Особенности конфигурации

### Ingress-Nginx
- Используется статический IP-адрес из outputs предыдущего state
- Версия chart: 4.12.2
- Namespace: `ingress-nginx`

### Cert-Manager
- Версия chart: v1.17.2
- Namespace: `cert-manager`
- Автоматически создается ClusterIssuer для Let's Encrypt
- Используется HTTP-01 challenge с Ingress класса nginx

### Argo CD
- Версия chart: 8.0.0
- Namespace: `argocd`
- Конфигурация берется из файла `argocd/values.yaml`

## Переменные

| Переменная | Значение по умолчанию | Описание |
|------------|-----------------------|----------|
| `kube_config_path` | `~/.kube/config` | Путь к kubeconfig файлу |

## Хранение состояния

Состояние Terraform хранится в Yandex Cloud Object Storage:
- Бакет: `vladis-terraform-state`
- Ключ: `kubernetes-application.tfstate`
- Регион: `ru-central1`

## Зависимости между компонентами

1. Сначала развертывается Cert-Manager
2. Затем Ingress-Nginx (зависит от Cert-Manager)
3. В последнюю очередь Argo CD (зависит от обоих предыдущих компонентов)



