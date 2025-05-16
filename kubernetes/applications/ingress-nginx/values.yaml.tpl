namespaceOverride: ingress-nginx
controller:
  allowSnippetAnnotations: true
  replicaCount: 1
  ingressClassResource:
    name: nginx
    enabled: true
    default: true
    controllerValue: "k8s.io/ingress-nginx"

  config:
    # Print access log to file instead of stdout
    # Separating acces logs from the rest
    # access-log-path: "/data/access.log"
    annotations-risk-level: "Critical"
    strict-validate-path-type: "false"
    use-forwarded-headers: "true"
    enable-real-ip: "true"
    custom-http-errors: >-
      403,404,500,501,502,503
    log-format-escape-json: "true"
    log-format-upstream: '{"source": "nginx", "time": $msec, "resp_body_size": $body_bytes_sent, "request_host": "$http_host", "request_address": "$remote_addr", "request_length": $request_length, "request_method": "$request_method", "uri": "$request_uri", "status": $status,  "user_agent": "$http_user_agent", "resp_time": $request_time, "upstream_addr": "$upstream_addr"}'

  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: "app.kubernetes.io/name"
            operator: In
            values:
            - ingress-nginx
        topologyKey: "kubernetes.io/hostname"

  minAvailable: 1
  # resources:
  #   requests:
  #     cpu: 100m
  #     memory: 90Mi

  service:
    enabled: true
    type: LoadBalancer
    loadBalancerIP: ${loadbalancer-ip}
  admissionWebhooks:
    enabled: false

  metrics:
    enabled: true
    service:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "10254"
  # priorityClassName: "medium-priority"

revisionHistoryLimit: 2
