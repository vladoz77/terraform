output "jenins_public_ip" {
  value = module.jenkins[*].public_ips
}

output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips
}

output "monitoring_public_ip" {
  value = try(module.monitoring[*].public_ips, [])
}







