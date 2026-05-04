# Pixel Tracker Infrastructure

Terraform project for deploying the first AWS infrastructure layer of the Pixel Tracker application.

The goal of this repository is to practice production-style infrastructure as code by building a small, understandable AWS environment that can later be configured with Ansible and deployed through CI/CD.

## What This Builds

- VPC for isolated networking
- Public subnet for internet-facing compute
- Private subnet for future internal services
- Internet gateway for public internet access
- Public route table and subnet association
- Private route table and subnet association
- Security group allowing HTTP from the internet and SSH from an approved CIDR
- EC2 instance running Amazon Linux 2023
- Docker installed on first boot through `user_data`
- Remote Terraform state using S3 and DynamoDB locking

## Architecture

```text
Internet
   |
Internet Gateway
   |
Public Route Table
   |
Public Subnet
   |
EC2 Instance + Security Group

VPC
 |
Private Route Table
 |
Private Subnet
 |
Future internal services
```

## Terraform Thinking

The infrastructure starts from a simple goal:

> Run a Docker-capable EC2 instance on AWS, reachable over HTTP and manageable over SSH.

That goal maps to AWS objects:

| Need | AWS object | Terraform resource |
| --- | --- | --- |
| Isolated cloud network | VPC | `aws_vpc` |
| Place to launch the server | Subnet | `aws_subnet` |
| Internet access | Internet Gateway | `aws_internet_gateway` |
| Traffic path to internet | Route Table | `aws_route_table` |
| Connect route table to subnet | Route Table Association | `aws_route_table_association` |
| Firewall rules | Security Group | `aws_security_group` |
| Server | EC2 Instance | `aws_instance` |

Terraform uses references like `aws_vpc.main.id` and `aws_subnet.public.id` to build the dependency graph and decide the correct creation order.

The public subnet is public because its route table sends `0.0.0.0/0` traffic to the internet gateway. The private subnet has its own route table without a default internet route, so resources placed there are not directly reachable from the internet.

## Repository Structure

```text
versions.tf              Terraform version, provider version, and remote backend
providers.tf             AWS provider configuration and default tags
data.tf                  AMI lookup for Amazon Linux 2023
variables.tf             Input variables
network.tf               VPC, subnet, internet gateway, and routing
security.tf              Security group rules
compute.tf               EC2 instance and bootstrap script
outputs.tf               Useful values after deployment
terraform.tfvars.example Example local variable file
```

## Prerequisites

- AWS account
- Terraform installed
- AWS credentials configured locally
- Existing EC2 key pair named `pixel-tracker-key`, or override `key_name`
- Existing S3 backend bucket and DynamoDB lock table:
  - S3 bucket: `pixel-tracker-tfstate-is`
  - DynamoDB table: `pixel-tracker-tf-locks`

## Usage

Create a local variable file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your own public IP:

```hcl
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
```

Initialize Terraform:

```bash
terraform init
```

Format and validate:

```bash
terraform fmt
terraform validate
```

Review the plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Destroy when finished:

```bash
terraform destroy
```

## Security Notes

- SSH is restricted through `allowed_ssh_cidr`.
- HTTP is open to the internet because this is an internet-facing web server.
- Terraform state is stored remotely in S3 with DynamoDB locking.
- Local `.tfvars` and state files are ignored by Git.

## Next Improvements

- Add NAT gateway for private outbound internet access
- Replace EC2 bootstrap logic with Ansible configuration
- Deploy a containerized app with Docker
- Add GitHub Actions for Terraform formatting and validation
- Add monitoring and logs through CloudWatch
