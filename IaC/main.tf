# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Include the VPC module
module "vpc" {
  source = "./VPC"
}

# Include the ECR module
module "ecr" {
  source = "./ECR"
}

# Include the ECS module
# module "ecs" {
#   source     = "./ECS"
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnet_ids
#   ecr_repo_url = module.ecr.repository_url
#   depends_on = [module.vpc, module.ecr]
# }

# Include the IAM module
module "iam" {
  source = "./IAM"
}