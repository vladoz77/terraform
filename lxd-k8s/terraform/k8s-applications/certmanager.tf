resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io/"
  namespace  = "cert-manager"
  version    = "1.18.2"

  create_namespace = true

  values = [
    <<-EOT
    crds:
      enabled: true
      keep: false
    EOT
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
  YAML
}

resource "kubectl_manifest" "certificate" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ca
  namespace: cert-manager
spec:
  isCA: true
  subject:
    organizations:
      - "Vlad's homelab"
    organizationalUnits:
      - "Home lab"
    localities:
      - "Ryazan"
    countries:
      - "RU"
  commonName: ca
  secretName: ca-secret
  privateKey:
    encoding: PKCS8
    algorithm: RSA
    size: 4096
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
  YAML
}

resource "kubectl_manifest" "caissuer" {
  depends_on = [helm_release.cert-manager]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-secret
  YAML
}