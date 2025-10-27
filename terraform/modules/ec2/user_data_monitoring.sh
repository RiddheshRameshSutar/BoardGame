#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Monitoring Server Setup ==="
echo "Project: ${project_name}"
echo "Environment: ${environment}"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install basic tools
echo "Installing basic tools..."
apt-get install -y curl wget git vim unzip

# Install Docker
echo "Installing Docker..."
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Create monitoring directory structure
echo "Creating monitoring directories..."
mkdir -p /opt/monitoring/{prometheus,grafana,alertmanager}
chown -R ubuntu:ubuntu /opt/monitoring

# Create Prometheus configuration
cat <<EOF > /opt/monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Load rules once and periodically evaluate them
rule_files:
  # - "alerts.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter on monitoring server
  - job_name: 'monitoring-server'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          instance: 'monitoring-server'

  # Add application server node exporter
  # - job_name: 'app-server'
  #   static_configs:
  #     - targets: ['APP_SERVER_IP:9100']
  #       labels:
  #         instance: 'app-server'
EOF

chown -R ubuntu:ubuntu /opt/monitoring/prometheus

# Create Docker Compose file for monitoring stack
cat <<EOF > /opt/monitoring/docker-compose.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    restart: unless-stopped
    networks:
      - monitoring

volumes:
  prometheus-data:
  grafana-data:

networks:
  monitoring:
    driver: bridge
EOF

chown -R ubuntu:ubuntu /opt/monitoring/docker-compose.yml

# Start monitoring stack
echo "Starting monitoring stack..."
cd /opt/monitoring
docker-compose up -d

# Wait for services to start
sleep 10

# Check if services are running
docker-compose ps

# Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
aws --version

echo "=========================================="
echo "Monitoring Server Setup Complete!"
echo "=========================================="
echo "Prometheus URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
echo "Grafana URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "Grafana Credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo "Node Exporter: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100"
echo "=========================================="

echo "=== Monitoring Server Setup Completed ==="
