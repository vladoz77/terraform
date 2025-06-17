output "plane_public_ip" {
  value = flatten(module.plane[*].public_ips)[0]
}

# output "backend_public_ip" {
#   value = flatten(module.backend[*].public_ips)[0]
# }

# output "runner_public_ip" {
#   value = flatten(module.runner[*].public_ips)[0]
# }

# output "monitoring_public_ip" {
#   value = flatten(module.monitoring[*].public_ips)[0]
# }