variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "itemboard"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "itemboard-ecr"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "itemboard-ecs-cluster"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "itemboard-ecs"
}