output "monitoring_public_ip" {
  value = try(module.monitoring[*].public_ips, [])
}

output "fqdn" {
  description = "Full FQDN of instances"
  value = flatten([
    for instance in module.monitoring : [
      for name in instance.fqdn : [
        "${name}.${data.terraform_remote_state.network.outputs.zone_name}"
      ]
    ]
  ])
}





