locals {
      masters_ip = {
        for key, value in var.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "master")
      }
      
      workers_ip = {
        for key, value in var.instances :
        key => module.instance[key].ipv4_address
        if startswith(key, "worker")
      }
}