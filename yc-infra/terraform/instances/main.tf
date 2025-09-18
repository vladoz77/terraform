module "jenkins" {
  source = "../modules/yc-instance"

  count = var.jenkins.count

  name          = "${var.jenkins.instance_name}-${count.index + 1}"
  zone          = var.zone
  platform_id   = var.platform_id
  cores         = var.jenkins.cpu
  memory        = var.jenkins.memory
  core_fraction = var.jenkins.core_fraction
  ssh  = "${var.username}:${var.ssh_key}"
  tags = var.jenkins.tags
  boot_disk = var.jenkins.boot_disk
  labels           = {}
  additional_disks = []
  env_vars         = var.jenkins.environment
  cloud_init       = ""
  network_interfaces = [
    {
      subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
      nat            = true
      security_group = []
    }
  ]
}

module "jenkins-agent" {
  source = "../modules/yc-instance"

  count = var.jenkins-agent.count

  name          = "${var.jenkins-agent.instance_name}-${count.index + 1}"
  zone          = var.zone
  platform_id   = var.platform_id
  cores         = var.jenkins-agent.cpu
  memory        = var.jenkins-agent.memory
  core_fraction = var.jenkins-agent.core_fraction
  ssh = "${var.username}:${var.ssh_key}"
  tags = var.jenkins-agent.tags
  boot_disk = var.jenkins-agent.boot_disk
  labels           = {}
  additional_disks = []
  env_vars         = var.jenkins-agent.environment
  cloud_init       = ""
  network_interfaces = [
    {
      subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
      nat            = true
      security_group = []
    }
  ]
}

module "monitoring" {
  source = "../modules/yc-instance"
  count  = contains(["prod", "stage"], var.environment) ? 1 : 0

  name          = "monitoring-${count.index + 1}"
  zone          = var.zone
  platform_id   = var.platform_id
  cores         = var.monitoring.cpu
  memory        = var.monitoring.memory
  core_fraction = var.monitoring.core_fraction
  ssh  = "${var.username}:${var.ssh_key}"
  tags = var.monitoring.tags
  boot_disk = var.monitoring.boot_disk
  labels           = {}
  additional_disks = []
  env_vars         = var.monitoring.environment
  cloud_init       = ""
  network_interfaces = [
    {
      subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
      nat            = true
      security_group = []
    }
  ]
}

resource "yandex_dns_recordset" "yc_records" {
  count = length(module.jenkins) > 0 && contains(["prod", "stage"], var.environment) ? 1 : 0

  zone_id = data.terraform_remote_state.network.outputs.zone_id
  name = var.yc_dns_records
  type = "A"
  ttl  = 300
  data = module.jenkins[0].public_ips

  depends_on = [module.jenkins]
}

resource "yandex_dns_recordset" "monitoring_records" {
  count = length(module.monitoring) > 0 ? 1 : 0
  
  zone_id = data.terraform_remote_state.network.outputs.zone_id
  name = var.monitoring_dns_records
  type = "A"
  ttl  = 300
  data = module.monitoring[0].public_ips

  depends_on = [module.monitoring]
}
