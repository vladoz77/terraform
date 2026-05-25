module "metallb" {
  source = "./modules/metallb"
  
  name             = "metallb"
  namespace        = "metallb-system"
  chart_version    = "0.15.3"
  create_namespace = true
  ippools          = {
    "system-pool" = ["172.18.255.200-172.18.255.250"]
    "production-pool" = ["10.0.1.0/24"]
  }
}