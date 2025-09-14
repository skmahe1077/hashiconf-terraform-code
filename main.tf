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

resource "aws_s3_bucket" "hashiconf_bucket" {
  bucket = "sentinel-demo-public-${random_id.suffix.hex}"
  tags = {
    Name = "sentinel-demo-public"
  }
}

resource "aws_s3_bucket_acl" "public_acl" {
  bucket = aws_s3_bucket.hashiconf_bucket.id
  acl    = "public-read"
}

