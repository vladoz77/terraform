lxd_profile_name = "k8s-profile"
lxd_image_os = "fedora"
environment = "dev"


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
    cpu          = "4"
    memory       = "4GB"
    volumes = {}
  
  }
  worker-01 = {
    type         = "virtual-machine"
    root_disk_size = "30GB"
    ipv4_address = "192.168.200.3"
    cpu          = "4"
    memory       = "4GB"
    volumes = {
      data = {
        size = "30GB"
        pool = "data-k8s"
      }
    }
  }
}