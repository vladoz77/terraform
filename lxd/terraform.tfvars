lxd_profile_name = "instance_profile"

network = {
  ipv4_address = "192.168.2.1/24"
  name         = "lxdbr1"
}

instance = {
  name           = "lxd-github-agent"
  image          = "32a5c526db8f"
  type           = "virtual-machine"
  ipv4_address   = "192.168.2.100"
  cpu            = 2
  memory         = "2GB"
  root_disk_size = "20GB"
}

