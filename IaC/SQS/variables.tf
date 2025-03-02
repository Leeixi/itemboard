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

variable "ecr_repository_name" {
  description = "Name of the ECR repository to monitor"
  type        = string
  default     = "itemboard"
}