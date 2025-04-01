resource "yandex_vpc_security_group" "vpc_group" {
  name = "security_group"
  network_id = yandex_vpc_network.network.id
  description = "test sg"

  ingress {
    protocol = "TCP"
    port = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "TCP"
    port = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }




}