locals {
  common_instances = {
    monitoring = {
        enable = true
        count = 2
        vcpu = 2
        memory = 4096
        disk_size = 100
        ip_addresses = [
          "172.16.10.100",
          ]
    }
    runner = {
        enable = false
        count = 2
        vcpu = 2
        memory = 2048
        disk_size = 100
        ip_addresses = []
    }
  }
}