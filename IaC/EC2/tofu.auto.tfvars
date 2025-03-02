# Required variables
vpc_id           = "vpc-043e1f77871f5f90b"            # Your VPC ID
subnet_id        = "subnet-0f77a37a740d3f609"         # Your subnet ID where the EC2 should be launched
key_name         = "itemboard-ec2-keypair-2"        # The name of your SSH key pair in AWS
security_group_id = "sg-091f53b23c513f5e7"            # ID of your itemboard_tasks security group

# Optional variables with defaults
aws_region      = "eu-central-1"               # AWS region
project_name    = "itemboard"                  # Project name
instance_type   = "t2.micro"
itemboard-ec2-sg = "22"