output "jenins_public_ip" {
  value = module.jenkins[*].public_ips
}

output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips
}








