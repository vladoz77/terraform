1. Create vault file

```bash
ansible-vault create provision/group_vars/all/vault.yaml
```

2. Add secret variables

```bash
sonarqube_default_admin_password: ****
sonarqube_new_admin_password: ****
sonarqube_password: ****
```

3. Add this vault file to role
In file `roles/sonarqube/tasks/main` add this string

```yaml
- name: Load Vault variables
  ansible.builtin.include_vars:
    file: ../../group_vars/all/vault.yaml
    name: vault_secrets
```

4. Use secret variables in tasks

```yaml
- name: Check if admin password already changed
  ansible.builtin.uri:
    url: "{{ sonarqube_url }}/api/authentication/validate"
    method: GET
    user: admin
    password: "{{ vault_secret.sonarqube_default_admin_password }}"
    force_basic_auth: yes
    status_code: 200
  register: auth_check
  ignore_errors: yes
  changed_when: false
```

5. Run playbook with secret

```bash
ansible-playbook -i provision/inventory.ini provision/jenkins.yaml -u ubuntu --ask-vault-pass
```