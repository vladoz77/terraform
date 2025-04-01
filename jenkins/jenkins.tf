module "jenkins" {
  source = "../tf-modules/instance"

  count = 1

  name = "${local.jenkins.instance_name}-${count.index + 1}"
  zone = local.jenkins.instance_zone
  platform_id = local.jenkins.instance_platform_id
  cores = local.jenkins.instance_core
  memory = local.jenkins.instance_memory
  core_fraction = local.jenkins.instance_core_fraction
  ssh = "${var.username}:${var.ssh_key}"
  tags  = local.jenkins.instance_tag
  network_interfaces = local.jenkins.instance_network_interface
  boot_disk = local.jenkins.instance_boot_disk
  labels = {}
  additional_disks = local.jenkins.other_disks
  env_vars = local.jenkins.environment
}