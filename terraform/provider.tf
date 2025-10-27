# Provider configuration for AWS
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for state file (optional but recommended)
  backend "s3" {
    bucket         = "boardgame-terraform-state-bucket"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "BoardGameWebApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Riddhesh Sutar"
    }
  }
}
