# Публичные IP-адреса виртуальных машин Jenkins
output "jenins_public_ip" {
  value = module.jenkins[*].public_ips    
}

# Публичные IP-адреса виртуальных машин Jenkins Agent
output "jenkins-agent_public_ip" {
  value = module.jenkins-agent[*].public_ips  
}










