resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_security_group" "ec2_security_group" {
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

resource "aws_instance" "public-ip" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true 
  vpc_security_group_ids      = [aws_security_group.bad_open.id]

  tags = { Name = "sentinel-demo-ec2-public" }
}

resource "aws_ebs_volume" "hashiconf-volume" {
  availability_zone = "${var.region}${var.az_suffix}"
  size              = 8
  encrypted         = false                  
  tags = { Name = "sentinel-demo-ebs-unencrypted" }
}

resource "aws_s3_bucket" "hashiconf_bucket" {
  bucket = "sentinel-demo-public-${random_id.suffix.hex}"
  tags = {
    Name = "sentinel-demo-public"
  }
}

resource "aws_s3_bucket_acl" "public_acl" {
  bucket = aws_s3_bucket.bad_public.id
  acl    = "public-read"
}

