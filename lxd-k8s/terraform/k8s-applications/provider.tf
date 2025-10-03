terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

}

provider "helm" {
  kubernetes = {
    config_path = var.kube_config_path
  }

}

provider "kubectl" {
  config_path = var.kube_config_path
}