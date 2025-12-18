lxd_profile_name = "k8s-profile"
lxd_image_os = "95d7dd7c6554"
environment = "dev"


pools = {
  "root-k8s" = {
    pool_driver = "dir"
    pool_source = "/mnt/lxd-pools/root-k8s"
  }
  "data-k8s" = {
    pool_driver = "dir"
    pool_source = "/data/k8s-data"
  }
}

instances = {
  master-01 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "192.168.200.2"
    cpu          = "4"
    memory       = "4GB"
    volumes = {
      data = {
        size = "20GB"
        pool = "data-k8s"
      }
    }
  }
  worker-01 = {
    type         = "virtual-machine"
    root_disk_size = "30GB"
    ipv4_address = "192.168.200.3"
    cpu          = "2"
    memory       = "4GB"
    volumes = {
      data = {
        size = "30GB"
        pool = "data-k8s"
      }
    }
  }
  worker-02 = {
    type         = "virtual-machine"
    root_disk_size = "30GB"
    ipv4_address = "192.168.200.4"
    cpu          = "2"
    memory       = "3GB"
    volumes = {
      data = {
        size = "30GB"
        pool = "data-k8s"
      }
    }
  }
  worker-03 = {
    type         = "virtual-machine"
    root_disk_size = "30GB"
    ipv4_address = "192.168.200.5"
    cpu          = "2"
    memory       = "3GB"
    volumes = {
      data = {
        size = "30GB"
        pool = "data-k8s"
      }
    }
  }
}
