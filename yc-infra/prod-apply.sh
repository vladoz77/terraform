#! /bin/bash
# update yandex token
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token) > /dev/null

# Go to terraform dev dir
cd terraform/jenkins/prod

# Terraform run
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform init
terraform plan 
terraform apply  -auto-approve 

# Install monitoring
cd ../../monitoring/
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform init
terraform plan 
terraform apply  -auto-approve 

# Ansible provision
# sleep 30
cd ../../ansible/
ansible-playbook -i inventory/monitoring/inventory.ini  playbooks/jenkins-install-prod.yaml -u ubuntu 
ansible-playbook -i inventory/jenkins/prod/inventory.ini  playbooks/jenkins-install-prod.yaml -u ubuntu 
