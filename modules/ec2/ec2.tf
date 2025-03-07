resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile

  tags = {
    Name = "WebServer"
  }
}
