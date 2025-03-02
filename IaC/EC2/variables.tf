# Configure AWS provider
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "itemboard"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" 
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to deploy the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "ID of the itemboard_tasks security group"
  type        = string 
}