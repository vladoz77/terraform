1. Change admin password

```bash
SONAR_URL=https://sonarqube.home-local.site
OLD_PASSWORD='!QAZ2wsx#EDC4rfv'
NEW_PASSWORD='Qwerty123456789@'
USER='jenkins'
GROUP='sonar-administrators'
```

```bash
curl -i -u admin:"${OLD_PASSWORD}" -X POST "${SONAR_URL}/api/users/change_password" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "login=admin&previousPassword=${OLD_PASSWORD}&password=${NEW_PASSWORD}"
```

2. Create user

```bash
curl -ifu admin:"${NEW_PASSWORD}" -X POST "${SONAR_URL}/api/v2/users-management/users" \
-H "Content-Type: application/json" \
-d '{
  "email": "jenkins@example.com",
  "local": "true",
  "login": "jenkins",
  "name": "jenkins",
  "password": "jenkins",
  "scmAccounts": [
    "string"
  ]
}'
```

2. Get userID

```bash
USERID=$(curl -u admin:"${NEW_PASSWORD}" -X GET "${SONAR_URL}/api/v2/users-management/users?q=${USER}" | jq -r --arg user "$USER" '.users[] | select(.name==$user) | .id')
```

3. Get GroupID

```bash
 GROUPID=$(curl -u admin:"${NEW_PASSWORD}" -X GET "${SONAR_URL}/api/v2/authorizations/groups?q=${GROUP}" | jq -r --arg group "$GROUP" '.groups[] | select(.name==$group) | .id')
```

4. Add user to group

```bash
curl -ifu admin:"${NEW_PASSWORD}" -X POST "${SONAR_URL}/api/v2/authorizations/group-memberships" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'"${USERID}"'",
    "groupId": "'"${GROUPID}"'"
  }'
```