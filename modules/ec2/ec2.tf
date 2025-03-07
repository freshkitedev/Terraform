resource "aws_instance" "web" {
  ami                    = "ami-02c78647b95a018b6"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  security_groups        = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "WebServer"
  }
}
