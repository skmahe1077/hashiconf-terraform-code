resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "sentinel-demo-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id
  tags   = { Name = "sentinel-demo-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true   # public subnet
  tags = { Name = "sentinel-demo-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
  tags   = { Name = "sentinel-demo-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_security_group" "bad_open" {
  name        = "sentinel-demo-open-sg-${random_id.suffix.hex}"
  description = "Intentionally open SG to trigger Sentinel/CIS"
  vpc_id      = aws_vpc.demo.id
  ingress {
    description      = "SSH open to world"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sentinel-demo-open-sg" }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bad_public" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true 
  vpc_security_group_ids      = [aws_security_group.bad_open.id]

  tags = { Name = "sentinel-demo-ec2-public" }
}

resource "aws_ebs_volume" "bad_unencrypted" {
  availability_zone = "${var.region}${var.az_suffix}"
  size              = 8
  encrypted         = false                  
  tags = { Name = "sentinel-demo-ebs-unencrypted" }
}


