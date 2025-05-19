resource "helm_release" "cert-manager" {
  name = "cert-manager"
  chart = "cert-manager"
  repository = "https://charts.jetstack.io/"
  namespace = "cert-manager"
  version = "v1.17.2"
  create_namespace = true

  set {
    name = "crds.enabled"
    value = true
  }

}

resource "null_resource" "check_crd_ready" {
  depends_on = [ helm_release.cert-manager ]

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=Established --timeout=60s crd issuers.cert-manager.io"
  }
}


resource "null_resource" "cluster_issuer" {
  depends_on = [null_resource.check_crd_ready]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-issuer
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          email: vladoz77@yandex.ru
          privateKeySecretRef:
            name: ca-issuer
          solvers:
          - http01:
              ingress:
                ingressClassName: nginx
      EOF
    EOT
  }
}