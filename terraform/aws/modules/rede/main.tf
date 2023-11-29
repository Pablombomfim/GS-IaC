resource "aws_vpc" "vpc" {
  cidr_block = "20.0.0.0/16"
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "20.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "20.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg-load-balancer" {
  name        = "sgloadbalancer"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg-ec2" {
  name        = "sgec2"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Ec2-sub-1" {
  count                       = 2
  subnet_id                   = aws_subnet.subnet-1.id
  ami                         = "ami-0230bd60aa48260c6"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg-ec2.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo echo "pagina web do balacobaco" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "Ec2-sub-2" {
  count                       = 2
  subnet_id                   = aws_subnet.subnet-2.id
  ami                         = "ami-0230bd60aa48260c6"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sg-ec2.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "pagina web do balacobaco 2 o inimigo agora é outro" | sudo tee /var/www/html/index.html
              sudo systemctl status httpd
              EOF
}


resource "aws_lb_target_group" "ec2-lb" {
  name     = "ec2-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "ec2-sub-1-lb" {
  for_each         = { for i in aws_instance.Ec2-sub-1 : i.id => i }
  target_group_arn = aws_lb_target_group.ec2-lb.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2-sub-2-lb" {
  for_each         = { for i in aws_instance.Ec2-sub-2 : i.id => i }
  target_group_arn = aws_lb_target_group.ec2-lb.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb" "ec2_lb" {
  name               = "ec2-lb"
  security_groups    = [aws_security_group.sg-load-balancer.id]
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "ec2-lb-listener" {
  load_balancer_arn = aws_lb.ec2_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ec2-lb.arn
    type             = "forward"
  }
}
