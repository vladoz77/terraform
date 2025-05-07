# Блок конфигурации Terraform
terraform {
  # Настройка необходимых провайдеров
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"  # Источник провайдера Yandex Cloud
      version = "0.134.0"              # Версия провайдера
    }
  }

  # Конфигурация бэкенда для хранения состояния Terraform в Yandex Object Storage
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"  # Конечная точка Object Storage
    }
    bucket = "vladis-terraform-state"         # Имя бакета для хранения состояния
    region = "ru-central1"                    # Регион бакета
    key    = "jenkins.tfstate"                # Имя файла состояния

    # Различные флаги для работы с Yandex Object Storage
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }

  required_version = ">=1.9.8"  # Минимальная требуемая версия Terraform
}

# Настройка провайдера Vault для работы с секретами
provider "vault" {
  address          = "http://127.0.0.1:8200"  # Адрес сервера Vault
  skip_child_token = true
  # Метод аутентификации - AppRole
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.role_id    # ID роли из переменных
      secret_id = var.secret_id  # Секретный ID из переменных
    }
  }
}

# Получение секретов из Vault
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv"          # Точка монтирования секретов
  name  = "yc-sa-admin" # Имя секрета
}

# Настройка провайдера Yandex Cloud
provider "yandex" {
  token     = data.vault_kv_secret_v2.yc_creds.data["iam_token"]  # IAM-токен из Vault
  cloud_id  = data.vault_kv_secret_v2.yc_creds.data["cloud_id"]   # ID облака из Vault
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]  # ID каталога из Vault
  zone      = var.zone  # Зона доступности из переменных
}