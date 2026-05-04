variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "pixel-tracker"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region where resources are deployed."
  type        = string
  default     = "eu-central-1"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
  default     = "eu-central-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "Public CIDR block allowed to SSH into the EC2 instance. Use your public IP with /32."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block, for example 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the web server."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name used for SSH access."
  type        = string
  default     = "pixel-tracker-key"
}
