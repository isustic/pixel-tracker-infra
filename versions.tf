terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "pixel-tracker-tfstate-is"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "pixel-tracker-tf-locks"
    encrypt        = true
  }
}
