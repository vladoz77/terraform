apiVersion: v1
clusters:
- cluster:
    server: ${server_url}
    certificate-authority-data: ${ca_certificate}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: yc
  name: ${cluster_name}
current-context: ${cluster_name}
users:
- name: yc
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: yc
      args:
      - k8s
      - create-token