locals {
  count = 1
  network = {
    cidr = "172.16.10.0/24"
  }
  instance = {
    name = "instance"
    vcpu = 1
    memory = 1024
    disk_size = 100
    disk_type = "basic.ru-7a"
    cloud_init = file("${path.module}/cloud-init.yaml")
  }
}

