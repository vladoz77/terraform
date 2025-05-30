data "http" "auth" {
  url = "https://cloud.api.selcloud.ru/identity/v3/auth/tokens"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    auth = {
      identity = {
        methods  = ["password"]
        password = {
          user = {
            name     = var.username
            domain   = { name = var.account_id }
            password = var.password
          }
        }
      }
      scope = {
        domain = { name = var.account_id }
      }
    }
  })
}

locals {
  api_token = data.http.auth.response_headers.X-Subject-Token
}

data "http" "keypairs" {
  url = "https://api.selectel.ru/vpc/resell/v2/keypairs"
  request_headers = {
    "X-Auth-Token" = local.api_token
  }
}

locals {
  keypairs = jsondecode(data.http.keypairs.response_body).keypairs
}

data "cloudinit_config" "devops_factory" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = yamlencode({
      ssh_pwauth  = "false"
      write_files = [{
        encoding    = "b64"
        content     = "UGVybWl0Um9vdExvZ2luIG5vCg=="
        owner       = "root:root"
        path        = "/etc/ssh/sshd_config.d/90-no_root.conf"
        permissions = "0644"
      }]
      groups = ["devops-factory"]
      users  = [
        for keypair in local.keypairs : {
          name                  = replace(keypair.name, " ", "_")
          sudo                  = ["ALL=(ALL) NOPASSWD:ALL"]
          groups                = ["devops-factory"]
          ssh_authorized_keys   = [keypair.public_key]
          shell                 = "/bin/bash"
        }
      ]
      runcmd = [
        [ "systemctl", "restart", "sshd" ]
      ]
    })
  }
}

