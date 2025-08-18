output "vm_name" {
  value = lxd_instance.instance.name
  description = "Virtual machine name"
}

output "vm_ipv4_address" {
  value = lxd_instance.instance.ipv4_address
}