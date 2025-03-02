data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Reference existing security group
data "aws_security_group" "itemboard_tasks" {
  id = var.security_group_id
}

# Create EC2 instance
resource "aws_instance" "debian_server" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [data.aws_security_group.itemboard_tasks.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-debian-server"
    Project = var.project_name
  }
  
  # User data script to run on instance startup
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
    apt-get install -y htop vim git
    
    # Set timezone
    timedatectl set-timezone UTC
    
    # Configure SSH for security
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF
}

# Optional: Create Elastic IP for the instance
resource "aws_eip" "debian_server" {
  instance = aws_instance.debian_server.id
  domain   = "vpc"
  
  tags = {
    Name    = "${var.project_name}-debian-server-eip"
    Project = var.project_name
  }
}