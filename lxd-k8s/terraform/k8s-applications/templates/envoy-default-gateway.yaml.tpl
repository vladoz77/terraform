apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: default-gateway
  namespace: ${namespace}
  annotations:
    cert-manager.io/cluster-issuer: ${cluster_issuer}
spec:
  gatewayClassName: ${gateway_class}
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
  - name: https
    protocol: HTTPS
    port: 443
    hostname: "${wildcard}"
    allowedRoutes:
      namespaces:
        from: All
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: ${cert_secret}