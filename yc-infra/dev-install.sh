#! /bin/bash
# update yandex token
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token) > /dev/null

# Go to terraform dir
cd terraform/instances

# Terraform run
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform plan -var-file environments/dev.tfvars
terraform apply -var-file environments/dev.tfvars -auto-approve 

# Ansible provision
sleep 30
cd ../../ansible/ 
ansible-playbook -i inventory/dev/inventory.ini  playbooks/all-install-dev.yaml -u ubuntu 
