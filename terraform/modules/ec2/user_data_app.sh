#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Application Server Setup ==="
echo "Project: ${project_name}"
echo "Environment: ${environment}"
echo "App Port: ${app_port}"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install basic tools
echo "Installing basic tools..."
apt-get install -y curl wget git vim unzip

# Install Java 17
echo "Installing Java 17..."
apt-get install -y openjdk-17-jdk
java -version

# Install Docker
echo "Installing Docker..."
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install Node Exporter for Prometheus
echo "Installing Node Exporter..."
useradd --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.6.1.linux-amd64*

# Create systemd service for node_exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# Verify Node Exporter is running
systemctl status node_exporter --no-pager

# Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
aws --version

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/boardgame-app
chown -R ubuntu:ubuntu /opt/boardgame-app

# Install CloudWatch agent
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Create application service template
cat <<EOF > /opt/boardgame-app/boardgame.service.template
[Unit]
Description=Board Game Listing Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/boardgame-app
ExecStart=/usr/bin/java -jar /opt/boardgame-app/boardgame.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "=========================================="
echo "Application Server Setup Complete!"
echo "=========================================="
echo "Application Directory: /opt/boardgame-app"
echo "Node Exporter running on port 9100"
echo "Ready to deploy application on port ${app_port}"
echo "=========================================="

echo "=== Application Server Setup Completed ==="
