lxd_profile_name = "k8s-profile"
lxd_image_os = "fedora43"
environment = "prod"

pools = {
  "root-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s"
  }
  "data-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/data-k8s"
  } 
}

instances = {
  master-01 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "192.168.200.2"
    cpu          = "2"
    memory       = "3GB"
    volumes = {
    }
  }
  master-02 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "192.168.200.3"
    cpu          = "2"
    memory       = "3GB"
    volumes = {}
  }
  master-03 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "192.168.200.4"
    cpu          = "2"
    memory       = "3GB"
    volumes = {}
  }
  worker-01 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "192.168.200.5"
    cpu          = "2"
    memory       = "3GB"
    volumes = {}
  }
}