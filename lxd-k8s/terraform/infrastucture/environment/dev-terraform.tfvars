lxd_profile_name = "k8s-profile"
lxd_image_os = "rocky-9-cloud"
environment = "dev"
lxd_server_cert_fingerprint = "ad87297baf75733c24eaaa23c349a9885a2814ee00121d19fbe127c5073515eb"
lxd_server_address = "https://rocky.homelab.local:8443"


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

network = {
  name = "lxdbr0"
  ipv4_address = "172.10.10.1/24"
  ipv6_address = "none"
  nat = true
  dhcp = true
  dns_domain = "cluster.local"
  dns_search = "cluster.local"
}


instances = {
  master-01 = {
    type         = "virtual-machine"
    root_disk_size = "20GB"
    ipv4_address = "172.10.10.10"
    cpu          = "2"
    memory       = "4GB"
    volumes = {}
  
  }
  worker-01 = {
    root_disk_size = "30GB"
    ipv4_address = "172.10.10.11"
    cpu          = "2"
    memory       = "4GB"
    volumes = {
      data = {
        size   = "30GB"
        pool = "data-k8s"
      }
    }
  }  
}