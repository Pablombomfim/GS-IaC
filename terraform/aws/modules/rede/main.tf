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
  key_name                    = "vockey"
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
  key_name                    = "vockey"
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


resource "aws_elb" "web" {
  name            = "web"
  subnets         = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  security_groups = [aws_security_group.sg-load-balancer.id]
  instances       = flatten([aws_instance.Ec2-sub-1.*.id, aws_instance.Ec2-sub-2.*.id])
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
