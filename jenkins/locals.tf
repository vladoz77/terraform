locals {
  network_name = "network"
  network_subnet = "network_subnet"
  network_cidr = "172.16.10.0/24"
  instance_name = "jenkins-vm"
  instance_zone = "ru-central1-a"
  instance_platform_id = "standard-v1"
  instance_core = 2
  instance_memory = 2
  instance_core_fraction = 20
  instance_disk_type = "network-hdd"
  instance_disk_size = 20
  instance_image_id = "fd81hgrcv6lsnkremf32"
  instance_tag = []
  instance_boot_disk = {
    disk_type = "network-hdd"
    disk_size = 20
    disk_image_id = "fd81hgrcv6lsnkremf32"
  }
  instance_network_interface = [
    {
        subnet_id  = yandex_vpc_subnet.subnet.id
        nat        = true
        security_group = [
          yandex_vpc_security_group.vpc_group.id
          ]
    }
  ]
  other_disks = [
    {
      size = 10
      type = "network-hdd"
    }
  ]
}