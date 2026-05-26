output "gateway_info" {
  value = {for key, val in var.gateway : key => {
    name           = key
    class_name     = val.class_name
    namespace      = val.namespace
    listeners      = [for l in val.listeners : {
      port      = l.port
      protocol  = l.protocol
    }]
  }}
}
