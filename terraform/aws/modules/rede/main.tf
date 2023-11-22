# RESOURCE: VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# RESOURCE: SUBNET
resource "aws_subnet" "subec2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

# RESOURCE: INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# RESOURCE: ROUTE TABLE
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
}

# RESOURCE: ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subec2.id
  route_table_id = aws_route_table.rt.id
}




