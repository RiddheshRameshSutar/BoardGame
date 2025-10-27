variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR blocks for SSH"
  type        = list(string)
}

variable "allowed_http_cidr" {
  description = "Allowed CIDR blocks for HTTP/HTTPS"
  type        = list(string)
}

variable "app_port" {
  description = "Application port"
  type        = number
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}
