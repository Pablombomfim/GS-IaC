resource "aws_vpc" "vpc" {
  cidr_block = "30.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "30.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "30.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "All trafic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All trafic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
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
resource "aws_instance" "ec2web" {
  ami                    = "ami-0230bd60aa48260c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("./modules/compute/init/instance.sh")
}

resource "aws_instance" "ec2web2" {
  ami                    = "ami-0230bd60aa48260c6"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = file("./modules/compute/init/instance.sh")
}

resource "aws_lb" "lb-gs" {
    name               = "lb-gs"
    security_groups    = [aws_security_group.sg.id]
    subnets            = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
    idle_timeout       = 400
    enable_deletion_protection = false
    enable_cross_zone_load_balancing = true
    internal           = false
    load_balancer_type = "application"
    enable_http2       = true

}

resource "aws_lb_target_group" "tg" {
  name     = "tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/"
    interval            = 30
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb-gs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}
