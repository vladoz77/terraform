# outputs.tf
output "instance_name" {
  value = lxd_instance.instance.name
}

output "ipv4_address" {
  value = var.instance.ipv4_address
}

output "profile_name" {
  value = lxd_profile.vm.name
}

# Добавьте дополнительные полезные outputs
output "volumes" {
  value = { for k, v in lxd_volume.volume : k => {
    name = v.name
    size = v.config.size
    pool = v.pool
  }}
}


