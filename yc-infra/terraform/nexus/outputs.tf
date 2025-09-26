output "public_ip" {
  value = module.nexus[*].public_ips
}


output "fqdn" {
  description = "Full FQDN of instances"
  value = flatten([
    for instance in module.nexus : [
      for name in instance.fqdn : [
        "${name}.${data.terraform_remote_state.network.outputs.zone_name}"
      ]
    ]
  ])
}