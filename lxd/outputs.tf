output "instance" {
  value = { for key, value in module.instance: key =>{
    name = value.instance_name
    ipv4 = value.ipv4_address
    profile = value.profile_name
    volumes = value.volumes
  } }
}

