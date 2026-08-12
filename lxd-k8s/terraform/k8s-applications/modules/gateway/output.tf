# output.tf
output "gateway_info" {
  value = {for key, val in var.gateway : key => {
    name           = key
    namespace      = val.namespace
    listeners      = [for l in val.listeners : {
      port      = l.port
      protocol  = l.protocol
    }]
  }}
}
