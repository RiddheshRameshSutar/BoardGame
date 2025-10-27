# Data source for latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name # Using existing key pair
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_sg_id]
  iam_instance_profile   = var.iam_instance_profile_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data_jenkins.sh", {
    project_name = var.project_name
    environment  = var.environment
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins-server"
      Role = "Jenkins"
    }
  )
}

# Application Server
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name # Using existing key pair
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.app_server_sg_id]
  iam_instance_profile   = var.iam_instance_profile_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data_app.sh", {
    project_name = var.project_name
    environment  = var.environment
    app_port     = var.app_port
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-server"
      Role = "Application"
    }
  )
}

# Monitoring Server (Prometheus & Grafana)
resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name # Using existing key pair
  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [var.monitoring_sg_id]
  iam_instance_profile   = var.iam_instance_profile_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data_monitoring.sh", {
    project_name = var.project_name
    environment  = var.environment
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-monitoring-server"
      Role = "Monitoring"
    }
  )
}

# Elastic IPs for servers
resource "aws_eip" "jenkins" {
  domain   = "vpc"
  instance = aws_instance.jenkins.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins-eip"
    }
  )
}

resource "aws_eip" "app_server" {
  domain   = "vpc"
  instance = aws_instance.app_server.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-eip"
    }
  )
}

resource "aws_eip" "monitoring" {
  domain   = "vpc"
  instance = aws_instance.monitoring.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-monitoring-eip"
    }
  )
}
