apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: ${endpoint}
    certificate-authority-data: ${ca_certificate}

users:
- name: ${user_name}
  user:
    token: ${token}

contexts:
- name: default-context
  context:
    cluster: ${cluster_name}
    user: ${user_name}

current-context: default-context