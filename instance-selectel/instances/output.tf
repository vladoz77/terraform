output "plane_public_ip" {
  value = flatten(module.plane[*].public_ips)
}

output "backend_public_ip" {
  value = flatten(module.backend[*].public_ips)
}
