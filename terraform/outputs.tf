# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# EC2 Outputs
output "jenkins_public_ip" {
  description = "Jenkins server public IP"
  value       = module.ec2.jenkins_public_ip
}

output "app_server_public_ip" {
  description = "Application server public IP"
  value       = module.ec2.app_server_public_ip
}

output "monitoring_public_ip" {
  description = "Monitoring server public IP"
  value       = module.ec2.monitoring_public_ip
}

# Access Information
output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${module.ec2.jenkins_public_ip}:8080"
}

output "application_url" {
  description = "Application URL"
  value       = "http://${module.ec2.app_server_public_ip}:2255"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${module.ec2.monitoring_public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${module.ec2.monitoring_public_ip}:3000"
}

# SSH Commands (using rrskey.pub)
output "ssh_jenkins" {
  description = "SSH command for Jenkins server"
  value       = "ssh -i rrskey.pub ubuntu@${module.ec2.jenkins_public_ip}"
}

output "ssh_app_server" {
  description = "SSH command for App server"
  value       = "ssh -i rrskey.pub ubuntu@${module.ec2.app_server_public_ip}"
}

output "ssh_monitoring" {
  description = "SSH command for Monitoring server"
  value       = "ssh -i rrskey.pub ubuntu@${module.ec2.monitoring_public_ip}"
}
