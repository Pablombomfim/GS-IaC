resource "aws_instance" "web" {
    count = 2
    ami           = "ami-0c94855ba95c574c8"
    instance_type = "t2.micro"
    key_name      = "my-key"
    user_data     = file("./modules/compute/init/instance.sh") 
    vpc_security_group_ids = [var.id-sg]
}

resource "aws_elb" "load_balancer" {
  name               = "load_balancer"
  security_groups    = [var.id-sg]
  availability_zones = ["us-west-1a", "us-west-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = aws_instance.web[*].id
}