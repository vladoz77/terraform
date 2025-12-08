#! /bin/bash
# update yandex token
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token) > /dev/null


# Go to terraform dev dir
cd terraform/monitoring
# Terraform run
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform init 
terraform plan 
terraform apply  -auto-approve 

# Ansible provision
export VAULT_SECRET_ID=$(vault write -f -format=json auth/approle/role/ansible-role/secret-id | jq -r .data.secret_id)
export VAULT_ROLE_ID=$(vault read  -format=json  auth/approle/role/ansible-role/role-id | jq -r .data.role_id)
sleep 45
cd ../../ansible/ 
ansible-playbook -i inventory/monitoring/inventory.ini  playbooks/monitoring-install.yaml -u ubuntu