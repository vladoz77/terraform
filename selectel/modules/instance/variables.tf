# Global config

variable "zone_id" {
  type = string
  description = "value"
}

variable "instance_name" {
  type = string
  description = "Instance name"
}

variable "cloud_init" {
  description = "YAML content for cloud-init configuration"
  type        = string
  default     = null
  sensitive   = false
  nullable = true
}

# Disk config
variable "disk_size" {
  type = number
  default = "50"
  description = "instance disk size"
}

variable "os_image_id" {
  type = string
  description = "Os image id"
}

variable "disk_type" {
  type = string
  description = "Instance disk type"
}

# Flavour config
variable "vcpu" {
  type = number
  default = 1
  description = "instance vcpu"
}

variable "memory" {
  type = number
  default = 1024
}

# Network config
variable "network_id" {
  type = string
  description = "Network id"
}

variable "subnet_id" {
  type = string
  description = "subnet id"
}

variable "port_id" {
  type = string
  description = "port_id"
}