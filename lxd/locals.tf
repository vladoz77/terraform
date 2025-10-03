locals {
  instances = {
    web = {
      cpu          = 2
      memory       = "2GB"
      ipv4_address = "192.168.200.10"
      volumes = {
        data = {
          size = "10GB"
        }
        logs = {
          size = "5GB"
        }
      }
    }
    db = {
      cpu          = 4
      memory       = "4GB"
      ipv4_address = "192.168.200.11"
      volumes = {
        pgdata = {
          size = "20GB"
        }
      }
    }
    srv = {
      cpu          = 2
      memory       = "2GB"
      ipv4_address = "192.168.200.12"
      volumes = {
        log = {
          size = "5GB"
        }
      }
    }
  }
}