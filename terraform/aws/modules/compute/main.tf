
resource "aws_instance" "web" {
  count                  = 2
  ami                    = "ami-0230bd60aa48260c6"
  subnet_id              = var.subnet_id
  instance_type          = "t2.micro"
  user_data              = file("./modules/compute/init/instance.sh")
  vpc_security_group_ids = [var.id-sg]
  associate_public_ip_address = true
}

