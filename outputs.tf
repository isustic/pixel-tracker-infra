output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = aws_subnet.private.id
}

output "web_instance_id" {
  description = "ID of the EC2 web instance."
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Public IP address of the EC2 web instance."
  value       = aws_instance.web.public_ip
}

output "ssh_command" {
  description = "Example SSH command for connecting to the EC2 instance."
  value       = "ssh ec2-user@${aws_instance.web.public_ip}"
}
