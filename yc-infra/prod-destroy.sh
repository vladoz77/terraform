#! /bin/bash
# update yandex token
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token) > /dev/null

# Go to terraform dev dir
cd terraform/jenkins/prod

# Terraform run
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform destroy  -auto-approve 

# Install monitoring
cd ../../monitoring/
export TF_VAR_ssh_key=$(cat /home/${USER}/.ssh/id_rsa.pub)
terraform destroy  -auto-approve 

