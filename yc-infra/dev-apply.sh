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
export VAULT_ROLE_ID=95b272fa-e628-a4f2-74b1-2c9713bab027
export VAULT_SECRET_ID=e3f2e2ad-9036-406d-5da2-234947d40c8f
sleep 45
cd ../../../ansible/ 
ansible-playbook -i inventory/jenkins/dev/inventory.ini  playbooks/jenkins-install-dev.yaml -u ubuntu 
