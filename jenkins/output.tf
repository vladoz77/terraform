
output "jenkins_name_vm" {
  value = module.jenkins[*].instance_name
}

output "jenins_public_ip" {
  value = module.jenkins[*].public_ips
}

output "jenkins_private_ip" {
  value = module.jenkins[*].private_ips
}

output "jenkins-agent_name_vm" {
  value = module.jenkins-agent[*].instance_name
}

output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips
}

output "jenkins-agent_private_ip" {
  value = module.jenkins-agent[*].private_ips
}















