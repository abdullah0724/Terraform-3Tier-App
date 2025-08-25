# Auto-generated Key Pair
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}-keypair"
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name        = "${var.project_name}-${var.environment}-keypair"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Save private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.main.private_key_pem
  filename = "${path.module}/${var.project_name}-${var.environment}-keypair.pem"
  
  # Set proper permissions for the private key
  file_permission = "0400"
}