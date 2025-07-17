terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create VPC (Virtual Private Cloud)
resource "aws_vpc" "python_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "python-app-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "python_igw" {
  vpc_id = aws_vpc.python_vpc.id

  tags = {
    Name = "python-app-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "python_public_subnet" {
  vpc_id                  = aws_vpc.python_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "python-app-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "python_public_rt" {
  vpc_id = aws_vpc.python_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.python_igw.id
  }

  tags = {
    Name = "python-app-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "python_public_rta" {
  subnet_id      = aws_subnet.python_public_subnet.id
  route_table_id = aws_route_table.python_public_rt.id
}

# Create Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  name        = "python-jenkins-security-group"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.python_vpc.id

  # SSH access (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins web interface (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "python-jenkins-sg"
  }
}

# Create Security Group for Python App Server
resource "aws_security_group" "python_app_sg" {
  name        = "python-app-security-group"
  description = "Security group for Python Flask application server"
  vpc_id      = aws_vpc.python_vpc.id

  # SSH access (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask default port (5000)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "python-app-sg"
  }
}

# Create SSH Key Pair for EC2 Access
resource "aws_key_pair" "python_key" {
  key_name   = "python-app-key"
  public_key = file("~/.ssh/python-app-key.pub")

  tags = {
    Name = "python-app-ssh-key"
  }
}

# Create Jenkins EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.python_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.python_public_subnet.id
  user_data              = file("user-data-jenkins.sh")

  tags = {
    Name = "Python-Jenkins-Server"
  }
}

# Create Python App EC2 Instance
resource "aws_instance" "python_app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.python_key.key_name
  vpc_security_group_ids = [aws_security_group.python_app_sg.id]
  subnet_id              = aws_subnet.python_public_subnet.id
  user_data              = file("user-data-python-app.sh")

  tags = {
    Name = "Python-App-Server"
  }
}
