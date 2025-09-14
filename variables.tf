variable "region" {
  description = "AWS region for the demo"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the demo"
  type        = string
  default     = "t3.micro"
}

variable "az_suffix" {
  description = "AZ suffix to place the EBS volume (e.g., a, b, c)"
  type        = string
  default     = "a"
}

