# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Include modules
module "vpc" {
  source = "./VPC"
}

module "sqs" {
  source = "./SQS"
}

module "ecr" {
  source = "./ECR"
}