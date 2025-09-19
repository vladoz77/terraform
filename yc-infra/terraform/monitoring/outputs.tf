output "monitoring_public_ip" {
  value = try(module.monitoring[*].public_ips, [])
}







