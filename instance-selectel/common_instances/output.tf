
output "runner_public_ip" {
  value = flatten(module.runner[*].public_ips)
}

output "monitoring_public_ip" {
  value = flatten(module.monitoring[*].public_ips)
}