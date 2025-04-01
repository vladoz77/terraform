output "jenkins-cloud_init" {
  value = module.jenkins[*].cloud_init
}

output "jenkins-agent-cloud_init" {
  value = module.jenkins-agent[*].cloud_init
}
output "jenkins_id" {
  value = module.jenkins[*].instance_id
}

output "jenkins-agent_id" {
  value = module.jenkins-agent[*].instance_id
}

output "jenins_public_ip" {
  value = module.jenkins[*].public_ips
}

output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips
}
output "jenkins_private_ip" {
  value = module.jenkins[*].private_ips
}

output "jenkins-agent_private_ip" {
  value = module.jenkins-agent[*].private_ips
}

output "jenkins_tag" {
  value = module.jenkins[*].tags
}

output "jenkins-agent_tag" {
  value = module.jenkins-agent[*].tags
}

output "jenkins_name_vm" {
  value = module.jenkins[*].instance_name
}

output "jenkins-agent_name_vm" {
  value = module.jenkins-agent[*].instance_name
}










