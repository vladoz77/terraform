#!/bin/bash

PRIVATE_KEY="$1"

# Сохраняем временный JSON-файл
cat > /tmp/sa-key.json <<EOF
{
  "id": "temp",
  "service_account_id": "temp",
  "created_at": "temp",
  "key_algorithm": "RSA_2048",
  "public_key": "temp",
  "private_key": "$PRIVATE_KEY"
}
EOF

# Получаем токен
TOKEN=$(curl -s -X POST \
  -H "Metadata-token: 1" \
  -d @/tmp/sa-key.json \
  https://iam.api.cloud.yandex.net/iam/v1/tokens  | jq -r .access_token)

# Сохраняем токен в файл
echo "$TOKEN" > ./iam_token.txt