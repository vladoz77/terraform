locals {
  instances = {
    web = {
        cpu = 2
        memory = "2GB"
        volume = {
            size = "10GB"
        }
        ipv4_address = "192.168.200.10"
    }
    db = {
        cpu = 4
        memory = "4GB"
        volume = {
            size = "20GB"
        }
        ipv4_address = "192.168.200.11"
    }
  }
}