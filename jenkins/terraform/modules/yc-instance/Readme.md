# Terraform Module: Yandex Cloud Compute Instance

## Overview
This Terraform module creates a virtual machine instance in Yandex Cloud with configurable parameters including CPU, memory, disk options, and network settings. It supports additional disks, static IP assignment, and cloud-init configuration.

## Features
- Creates VM instances with customizable compute resources
- Supports boot disk configuration with different types and sizes
- Optional additional disks
- Configurable network interfaces with NAT and security groups
- SSH key injection for remote access
- Cloud-init support for instance initialization
- Outputs instance IDs, IP addresses, and other metadata

## Usage

### Basic Example
```hcl
module "my_instance" {
  source = "path/to/module"

  name          = "my-vm"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  cores         = 2
  memory        = 4
  core_fraction = 20

  ssh = "ubuntu:ssh-rsa AAAAB3NzaC1yc2E..."

  boot_disk = {
    disk_image_id = "fd8vmcue7aajpmeo39kk"
    disk_type     = "network-hdd"
    disk_size     = 20
  }

  network_interfaces = [{
    subnet_id = "e9b6d4pe1vokasdf1234"
    nat       = true
  }]
}
```

### Variables Reference

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `platform_id` | string | Yandex instance platform ID | - |
| `zone` | string | Yandex Cloud zone | - |
| `name` | string | VM name | - |
| `core_fraction` | number | CPU core fraction (5-100) | 20 |
| `cores` | number | Number of CPU cores | 2 |
| `memory` | number | Memory in GB | 1 |
| `ssh` | string | SSH key for instance access | - |
| `tags` | list(string) | Tags for the VM | null |
| `network_interfaces` | list(object) | Network interface configuration | See below |
| `boot_disk` | object | Boot disk configuration | - |
| `additional_disks` | list(object) | Additional disks configuration | null |
| `labels` | map(string) | Resource labels | null |
| `env_vars` | map(string) | Environment variables | `{DB = "db.test.local"}` |
| `username` | string | Default user for VM | "ubuntu" |
| `cloud_init` | string | Cloud-init configuration | null |

#### Network Interface Object
```hcl
{
  subnet_id           = string  # Required
  nat                 = bool    # Default: true
  ip_address          = string  # Optional
  security_group      = set(string) # Optional
  static_nat_ip_address = string  # Optional static NAT IP
}
```

#### Boot Disk Object
```hcl
{
  disk_image_id = string  # Image ID
  disk_type     = string  # Type (network-hdd, network-ssd, etc.)
  disk_size     = number  # Size in GB
}
```

#### Additional Disk Object
```hcl
{
  size = number  # Size in GB
  type = string  # Type (network-hdd, network-ssd, etc.)
}
```

### Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | Created instance ID(s) |
| `public_ips` | Public IP address(es) |
| `private_ips` | Private IP address(es) |
| `tags` | Instance tags |
| `instance_name` | Instance name(s) |

## Advanced Features

### Static IP Assignment
To assign a static external IP:
```hcl
resource "yandex_vpc_address" "static_ip" {
  name = "my-static-ip"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

module "my_instance" {
  # ... other parameters ...
  network_interfaces = [{
    subnet_id           = "e9b6d4pe1vokasdf1234"
    nat                 = true
    static_nat_ip_address = yandex_vpc_address.static_ip.external_ipv4_address[0].address
  }]
}
```

### Cloud-init Configuration
```hcl
module "my_instance" {
  # ... other parameters ...
  cloud_init = <<-EOT
    #cloud-config
    packages:
      - nginx
    runcmd:
      - [systemctl, enable, nginx]
      - [systemctl, start, nginx]
  EOT
}
```

