variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Amazon Machine Image ID for EC2 instances"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"  # Ubuntu 20.04 LTS in us-east-1
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}
