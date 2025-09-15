resource "random_id" "suffix" {
  byte_length = 3
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch the default security group of the default VPC
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Get the subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "hashiconf_ec2_public" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  associate_public_ip_address = true 

  tags = {
    Name = "hashiconf-ec2-public"
  }
}

resource "aws_ebs_volume" "hashiconf_volume_unencrypted" {
  availability_zone = "${var.region}a"
  size              = 8
  encrypted         = false
  tags = {
    Name = "hashiconf-volume-unencrypted"
  }
}

resource "aws_security_group" "hashiconf_sg_open" {
  name        = "hashiconf-sg-open"
  description = "Non-compliant SG allowing SSH from the world"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH open to world"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]     
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hashiconf-sg-open"
  }
}

resource "aws_s3_bucket" "hashiconf_bucket" {
  bucket = "sentinel-demo-public-${random_id.suffix.hex}"
  tags = {
    Name = "sentinel-demo-public"
  }
}

resource "aws_s3_bucket_public_access_block" "hashiconf_bucket_block" {
  bucket                  = aws_s3_bucket.hashiconf_bucket.id
  block_public_acls        = false
  block_public_policy      = false
  ignore_public_acls       = false
  restrict_public_buckets  = false
}

