variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Jenkins instance type"
  type        = string
}

variable "key_name" {
  description = "Existing SSH key pair name in AWS"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "jenkins_sg_id" {
  description = "Jenkins security group ID"
  type        = string
}

variable "app_server_sg_id" {
  description = "App server security group ID"
  type        = string
}

variable "monitoring_sg_id" {
  description = "Monitoring security group ID"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}
