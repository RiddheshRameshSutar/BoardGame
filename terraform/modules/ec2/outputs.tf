output "jenkins_instance_id" {
  description = "Jenkins instance ID"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Jenkins public IP"
  value       = aws_eip.jenkins.public_ip
}

output "app_server_instance_id" {
  description = "App server instance ID"
  value       = aws_instance.app_server.id
}

output "app_server_public_ip" {
  description = "App server public IP"
  value       = aws_eip.app_server.public_ip
}

output "monitoring_instance_id" {
  description = "Monitoring instance ID"
  value       = aws_instance.monitoring.id
}

output "monitoring_public_ip" {
  description = "Monitoring public IP"
  value       = aws_eip.monitoring.public_ip
}
