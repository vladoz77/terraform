terraform {
  required_providers {
    selectel  = {
      source  = "selectel/selectel"
      version = "~> 6.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
  }
}


provider "selectel" {
  domain_name = var.selectel_domain_name
  username    = var.selectel_username
  password    = var.selectel_password
  auth_region = var.zone_id
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
}

resource "selectel_iam_serviceuser_v1" "instance-sa" {
  name         = "instance-admin"
  password     = "!QAZ2wsx"
  role {
    role_name  = "member"
    scope      = "project"
    project_id = var.project_id
  }
}

provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.selectel_domain_name
  tenant_id   = var.project_id
  user_name   = selectel_iam_serviceuser_v1.instance-sa.name
  password    = selectel_iam_serviceuser_v1.instance-sa.password
  region      = var.zone_id
}


# Добавить публичный SSH-ключ⁠
resource "selectel_vpc_keypair_v2" "ssh_key" {
  name       = "keypair"
  public_key = file("~/.ssh/id_rsa.pub")
  user_id    = selectel_iam_serviceuser_v1.instance-sa.id
}