# Required variables
vpc_id           = "vpc-0cf1c4e82a4b22e17"            
subnet_id        = "subnet-0306d891b75642643"         # Subnet ID where the EC2 should be launched
key_name         = "dlevacic-public"                  # The name of SSH key pair in AWS
security_group_id = "sg-0eb08cdd97ec301e9"            # ID of itemboard-tasks-sg

# Optional variables with defaults
aws_region      = "eu-central-1"               # AWS region
project_name    = "itemboard"                  # Project name
instance_type   = "t2.micro"