module "jenkins" {
  source = "../modules/yc-instance" 

  count = var.jenkins.count

  name = "${var.jenkins.instance_name}-${count.index + 1}" 
  zone = var.zone
  platform_id = var.platform_id
  cores = var.jenkins.cpu
  memory = var.jenkins.memory
  core_fraction = var.jenkins.core_fraction
  
  ssh = "${var.username}:${var.ssh_key}"
  tags  = var.jenkins.tags
  network_interfaces = [
      {
          subnet_id  = data.terraform_remote_state.network.outputs.subnet_id
          nat        = true         
          security_group = []       
      }
    ]

  boot_disk = {
    disk_type = var.disk_type
    disk_size = var.jenkins.disk_size
    disk_image_id = var.image_id
  }

  labels = {}  
  additional_disks = []
  env_vars = var.jenkins.environment
  cloud_init = ""
}

module "jenkins-agent" {
  source = "../modules/yc-instance"   

  count = var.jenkins-agent.count

  name = "${var.jenkins-agent.instance_name}-${count.index + 1}"
  zone = var.zone
  platform_id = var.platform_id
  cores = var.jenkins-agent.cpu
  memory = var.jenkins-agent.memory
  core_fraction = var.jenkins-agent.core_fraction
  
  ssh = "${var.username}:${var.ssh_key}"
  
  tags  = var.jenkins-agent.tags
  network_interfaces = [
      {
          subnet_id  = data.terraform_remote_state.network.outputs.subnet_id
          nat        = true
          security_group = []
      }
    ]

  boot_disk = {
    disk_type = var.disk_type
    disk_size = var.jenkins-agent.disk_size
    disk_image_id = var.image_id
  }

  labels = {}  
  additional_disks = []
  env_vars = var.jenkins-agent.environment
  cloud_init = ""
}

module "dns" {
  source = "../modules/yc-dns"

  create_zone = false
  
  zone_id = data.terraform_remote_state.network.outputs.zone_id
  dns_records = {
    wildcard-yc = {
        name = "*yc"
        type = "A"
        ttl = 300
        data = module.jenkins[0].public_ips
    }
  }
}