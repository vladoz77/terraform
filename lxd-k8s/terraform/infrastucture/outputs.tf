output "instance" {
  value = { for key, value in module.instance : key => {
    name    = value.instance_name
    ipv4    = value.ipv4_address
    volumes = value.volumes
  } }
}

output "storage_pools" {
  value = { for key, pool in lxd_storage_pool.pools : key => {
    name   = pool.name
    driver = pool.driver
    source = pool.source
  } }
}