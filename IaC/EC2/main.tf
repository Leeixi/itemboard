resource "aws_iam_role" "ec2_itemboard_role" {
  name = "ec2-itemboard-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-role"
    Project = var.project_name
  }
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.ec2_itemboard_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy" {
  role       = aws_iam_role.ec2_itemboard_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_itemboard_profile" {
  name = "ec2-itemboard-profile"
  role = aws_iam_role.ec2_itemboard_role.name
}

# Existing AMI data source
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

# Create EC2 instance with instance profile
resource "aws_instance" "debian_server" {
  ami                    = data.aws_ami.debian.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.itemboard_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_itemboard_profile.name  # Add the instance profile
  
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
    apt-get install -y htop vim git awscli docker.io
    
    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker
    
    # Set timezone
    timedatectl set-timezone UTC
    
    # Configure SSH for security
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # Install SSM Agent
    mkdir -p /tmp/ssm
    cd /tmp/ssm
    wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
    dpkg -i amazon-ssm-agent.deb
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF
  
  depends_on = [aws_security_group.itemboard_ec2_sg]
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

resource "aws_security_group" "itemboard_ec2_sg" {
  name        = "itemboard-ec2-sg"
  description = "Allow inbound traffic to itemboard EC2 instance"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Add ingress rule for the application port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "itemboard-ec2-sg"
  }
}