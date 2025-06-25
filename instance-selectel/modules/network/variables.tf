variable "cidr" {
  type = string
  description = "network cidr"
}

variable "network_name" {
  type = string
  default = "network"
  description = "Network name"
}

variable "subnet_name" {
  type = string
  default = "subnet"
  description = "Subnet name"
}

variable "router_name" {
  type = string
  default = "router"
  description = "Router name"
}

variable "external_network_id" {
  type = string
  description = "Externel network id"
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [ {
    name = "default-subnet"
    cidr = "172.16.10.0/24"
  } ]
}