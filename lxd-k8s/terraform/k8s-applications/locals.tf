locals {
  k8s_worker_node_names = {
    for name in data.terraform_remote_state.infrastucture.outputs.instance_names :
    name => "k8s-${name}"
    if startswith(name, "worker")
  }

    k8s_master_node_names = {
    for name in data.terraform_remote_state.infrastucture.outputs.instance_names :
    name => "k8s-${name}"
    if startswith(name, "master")
  }
}