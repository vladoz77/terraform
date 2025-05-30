locals {
  selectel_domain_name = "434613"
  project_id           = "223ff38b3c3c48c981c0b43ff5f39d32"
  network = {
    cidr = "172.16.10.0/24"
  }
  instance = {
    count      = 1
    name       = "plane"
    os_version = "Ubuntu 24.04 LTS 64-bit"
    vcpu       = 2
    memory     = 8192
    disk_size  = 100
    disk_type  = "basic.ru-7a"
    cloud_init = module.cloudinit.cloudinit
  }
}

