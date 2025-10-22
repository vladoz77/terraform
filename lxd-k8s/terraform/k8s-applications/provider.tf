terraform {
  required_version = ">= 1.9.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
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