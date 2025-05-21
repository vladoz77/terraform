resource "selectel_vpc_project_v2" "test" {
  name = "project"
}

resource "selectel_iam_serviceuser_v1" "instance-sa" {
  name         = "instance-admin"
  password     = "!QAZ2wsx"
  role {
    role_name  = "member"
    scope      = "project"
    project_id = selectel_vpc_project_v2.test.id 
  }
}

provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = "123456"
  tenant_id   = selectel_vpc_project_v2.test
  user_name   = selectel_iam_serviceuser_v1.instance-sa.name
  password    = selectel_iam_serviceuser_v1.instance-sa.password
  region      = "ru-9"
}