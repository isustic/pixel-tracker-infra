terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}


# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "pixel-tracker-vpc"
  }
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "pixel-tracker-public-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "pixel-tracker-igw"
  }
}


# Route table to point all traffic to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pixel-tracking-public-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group

resource "aws_security_group" "web_sg" {
  name        = "pixel-tracker-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id = aws_vpc.main.id

  # Inbound rule: allow SSH from my public IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["my_IP/32"]
    description = "SSH from my laptop"
  }

  # Inbound rule: allow HTTP from anywhere 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from the world"
  }

  # Allow all traffic out

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pixel-tracker-web-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami = "ami-09fc5668766215f32" // Amazon Linux 2023, eu-central-1
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name = "pixel-tracker-key"

  tags = {
    Name = "pixel-tracker-web"
  }

# user_data to install Docker on first boot
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
  EOF

}