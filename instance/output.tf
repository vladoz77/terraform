output "yandex_instance_id" {
  value = module.yandex-instance[*].instance_id
}

output "yandex_instance_public_ip" {
  value = module.yandex-instance[*].public_ips
}

output "yandex_instance_private_ip" {
  value = module.yandex-instance[*].private_ips
}

output "yandex_instance_tag" {
  value = module.yandex-instance[*].tags
}

output "yandex_name_vm" {
  value = module.yandex-instance[*].instance_name
}