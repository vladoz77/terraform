locals {
  instances = {
    master-01 = {
      cpu          = 4
      memory       = "4GB"
      ipv4_address = "192.168.200.2"
      volumes = {}
    }
    worker-01 = {
      cpu          = 4
      memory       = "4GB"
      ipv4_address = "192.168.200.3"
      volumes = {
        data = {
          size = "20GB"
        }
      }
    }
    worker-02 = {
      cpu          = 4
      memory       = "4GB"
      ipv4_address = "192.168.200.4"
      volumes = {
        data = {
          size = "20GB"
        }
      }
    }
  }
}