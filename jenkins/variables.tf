# Определение переменных Terraform

# Vault Role ID для аутентификации в Hashicorp Vault
variable "role_id" {
  description = "vault role"  # Описание назначения переменной
  type        = string        # Ожидаемый тип значения - строка
  # Примечание: Значение обычно задается через переменные окружения или terraform.tfvars
}

# Vault Secret ID для аутентификации в Hashicorp Vault
variable "secret_id" {
  description = "vault secret-id"  # Описание назначения переменной
  type        = string             # Ожидаемый тип значения - строка
  # Примечание: Это конфиденциальные данные, должны передаваться безопасным способом
}

# Зона доступности Yandex Cloud
variable "zone" {
  description = "zone for yc"      # Описание назначения переменной
  default     = "ru-central1-a"   # Значение по умолчанию
  type        = string            # Ожидаемый тип значения - строка
  # Примечание: Можно переопределить при вызове модуля
}

# Имя пользователя для SSH доступа
variable "username" {
  description = "username"        # Описание назначения переменной
  type        = string            # Ожидаемый тип значения - строка
  default     = "ubuntu"          # Значение по умолчанию (стандартный пользователь в Ubuntu)
}

# Публичный SSH-ключ для доступа к виртуальным машинам
variable "ssh_key" {
  description = "ssh-keys for host"  # Описание назначения переменной
  # Тип не указан, подразумевается string
  # Значение по умолчанию не задано, должно быть передано
  # Рекомендуемый способ передачи:
  # export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
  # или через terraform.tfvars
}

# variable "ansible_secret" {
#   description = "Password for ansible vault"
#   type = string
# }
# export TF_VAR_ansible_secret=
