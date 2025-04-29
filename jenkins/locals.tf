locals {
  # Config for network
  network = {
    network_name = "network"
    network_subnet = "network_subnet"
    network_cidr = "172.16.10.0/24"
  }
  # Config for jenkins-server
  jenkins = {
    instance_name = "jenkins-vm"
    instance_zone = "ru-central1-a"
    instance_platform_id = "standard-v1"
    instance_core = 2
    instance_memory = 4
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
          security_group = []
      }
    ]
    other_disks = [
      {
        size = 10
        type = "network-hdd"
      }
    ]
    environment = {
      DB_HOST = "db.home.local"
      APP_ENV = "test"
    }
  }
  # Config for jenkins-agent vm
  jenkins-agent = {
    instance_name = "jenkins-agent-vm"
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
          security_group = []
      }
    ]
    environment = {
      AGENT = "jenkins"
      APP_ENV = "test"
    }
  }
  
}