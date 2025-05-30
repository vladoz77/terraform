output "cloudinit" {
  value       = data.cloudinit_config.devops_factory.rendered
}

