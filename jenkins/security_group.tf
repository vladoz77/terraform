resource "yandex_vpc_security_group" "vpc_group" {
  name = "security_group"
  network_id = yandex_vpc_network.network.id
  description = "jenkins-sg"

  ingress {
    protocol = "TCP"
    port = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description = "accept all trafic to 22 port"
  }

  ingress {
    protocol = "TCP"
    port = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
    description = "accept all trafic to 8080 port"

  }

  ingress {
    protocol = "TCP"
    port = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description = "accept all trafic to 8080 port"
  }

   ingress {
    protocol = "ANY"
    from_port = 0
    to_port = 65535
    v4_cidr_blocks = ["172.16.10.0/24"]
    description = "accept all ingress trafic from cidr 172.16.10.0/24"
  }

  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description = "accept any egress trafic from any address"
  }

  egress {
    protocol = "ANY"
    from_port = 0
    to_port = 65535
    v4_cidr_blocks = ["172.16.10.0/24"]
    description = "accept egress trafic from CIDR 172.16.10.0/24"
  }
}