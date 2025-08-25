# Frontend EC2 Instance (Public)
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.frontend.id]
  subnet_id              = aws_subnet.public.id

  user_data = base64encode(templatefile("${path.module}/scripts/frontend-setup.sh", {
    backend_private_ip = aws_instance.backend.private_ip
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-frontend"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "frontend"
  }

  depends_on = [aws_instance.backend]
}

# Backend EC2 Instance (Private)
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.backend.id]
  subnet_id              = aws_subnet.private.id

  user_data = base64encode(templatefile("${path.module}/scripts/backend-setup.sh", {
    db_endpoint = aws_db_instance.main.endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "backend"
  }

  depends_on = [aws_db_instance.main]
}