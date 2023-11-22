resource "aws_security_group" "sg2" {
  name        = "Sgec2"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = var.vpc_id  

  ingress {
    description = "All the ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/16"]
  }
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = "ami-0230bd60aa48260c6"
  subnet_id              = var.subnet_id
  instance_type          = "t2.micro"
  user_data              = file("./modules/compute/init/instance.sh")
  vpc_security_group_ids = [aws_security_group.sg2.id]
  associate_public_ip_address = true
}

resource "aws_elb" "load_balancer" {
  name               = "loadbalancer"
  security_groups    = [aws_security_group.sg2.id]
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = aws_instance.web[*].id
}