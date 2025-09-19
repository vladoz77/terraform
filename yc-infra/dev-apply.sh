#! /bin/bash
# update yandex token
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token) > /dev/null

# Go to terraform dev dir
cd terraform/jenkins/dev

# Terraform run
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform init
terraform plan 
terraform apply  -auto-approve 

# Ansible provision
sleep 30
cd ../../../ansible/ 
ansible-playbook -i inventory/jenkins/dev/inventory.ini  playbooks/jenkins-install-dev.yaml -u ubuntu 
