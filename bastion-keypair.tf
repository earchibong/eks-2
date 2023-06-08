# Private Key and Keypair
## Create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key pair using above private key
resource "aws_key_pair" "instance_keypair" {
  key_name   = "eks-tf-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}

# Save the private key at the specified path
resource "local_file" "save-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${var.base_path}/${var.instance_keypair}.pem"
}
