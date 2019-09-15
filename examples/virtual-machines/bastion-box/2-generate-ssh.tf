resource "tls_private_key" "jumpserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

locals {
  public_ssh_key = "${tls_private_key.jumpserver.public_key_openssh}"
}
