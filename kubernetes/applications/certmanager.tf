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

resource "time_sleep" "wait_for_crd" {
  depends_on = [helm_release.cert-manager]
  create_duration = "60s"  # ← Ждём 60 секунд для установки CRD
}


resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-issuer"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email" = "vladoz77@yandex.ru"
        "privateKeySecretRef" = {
          "name" = "ca-issuer"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "ingressClassName" = "nginx"
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [time_sleep.wait_for_crd] 
}