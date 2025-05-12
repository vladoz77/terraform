

1. **Сменить пароль админа**

```bash
OLD_PASSWORD=$(docker exec nexus cat /nexus-data/admin.password)
NEW_PASSWORD="Qwerty123"
NEXUS_URL=https://nexus.home-local.site
```

```bash
curl  -if -X GET "${NEXUS_URL}/service/rest/v1/status" 
```

```bash
curl -ifu admin:"${OLD_PASSWORD}" \
  -X PUT -H 'Content-Type: text/plain' \
  --data "${NEW_PASSWORD}" \
  ${NEXUS_URL}/service/rest/v1/security/users/admin/change-password
```

## Создаем репозитарий docker-repo

```bash
curl -ifu admin:"${NEW_PASSWORD}" -X POST "${NEXUS_URL}/service/rest/v1/repositories/docker/hosted" \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "docker-repo",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "allow_once",
    "latestPolicy": true
  },
  "cleanup": {
    "policyNames": [
      "string"
    ]
  },
  "component": {
    "proprietaryComponents": true
  },
  "docker": {
    "v1Enabled": true,
    "forceBasicAuth": true,
    "httpPort": 8082,
    "subdomain": "docker-a"
  }
}'
```

3. **Создание роли**

```bash
curl  -ifu admin:"${NEW_PASSWORD}" -X POST "${NEXUS_URL}/service/rest/v1/security/roles" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "docker-role",
    "name": "Docker Read/Edit Access",
    "description": "Allows read and edit access to Docker repositories",
    "privileges": [
      "nx-repository-view-docker-*-add",
      "nx-repository-view-docker-*-browse",
      "nx-repository-view-docker-*-edit",
      "nx-repository-view-docker-*-read"
    ],
    "roles": []
  }'

```

4. **Создание нового пользователя**

```bash
curl -ifu admin:"${NEW_PASSWORD}" -X POST "${NEXUS_URL}/service/rest/v1/security/users" \
  -H 'Content-Type: application/json' \
  -d '{
  "userId": "jenkins",
  "firstName": "jenkins",
  "lastName": "jenkins",
  "emailAddress": "jenkins@example.com",
  "password": "jenkins",
  "status": "active",
  "roles": [
    "docker-role"
  ]
}'
```

