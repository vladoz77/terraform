module "jenkins-agent" {
  source = "../tf-modules/instance"

  count = 1

  name = "${local.jenkins-agent.instance_name}-${count.index + 1}"
  zone = local.jenkins-agent.instance_zone
  platform_id = local.jenkins-agent.instance_platform_id
  cores = local.jenkins-agent.instance_core
  memory = local.jenkins-agent.instance_memory
  core_fraction = local.jenkins-agent.instance_core_fraction
  ssh = "${var.username}:${var.ssh_key}"
  tags  = local.jenkins-agent.instance_tag
  network_interfaces = local.jenkins-agent.instance_network_interface
  boot_disk = local.jenkins-agent.instance_boot_disk
  labels = {}
  additional_disks = []
  env_vars = local.jenkins-agent.environment
}