# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
  common_tags          = var.common_tags
}

# Security Groups Module
module "security" {
  source = "./modules/security"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  project_name      = var.project_name
  environment       = var.environment
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  allowed_http_cidr = var.allowed_http_cidr
  app_port          = var.app_port
  common_tags       = var.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.instance_type
  jenkins_instance_type     = var.jenkins_instance_type
  key_name                  = var.key_name # Passing existing key name
  public_subnet_ids         = module.vpc.public_subnet_ids
  jenkins_sg_id             = module.security.jenkins_sg_id
  app_server_sg_id          = module.security.app_server_sg_id
  monitoring_sg_id          = module.security.monitoring_sg_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  app_port                  = var.app_port
  common_tags               = var.common_tags
}
