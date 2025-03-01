# Get account ID
data "aws_caller_identity" "current" {}

output "setup_instructions" {
  value = <<EOF
=======================================================
GitHub Actions IAM User Setup Complete
=======================================================

1. Add these secrets to your GitHub repository:

   AWS_ACCESS_KEY_ID: [Sensitive - See AWS Console]
   AWS_SECRET_ACCESS_KEY: [Sensitive - See AWS Console]
   AWS_REGION: ${var.aws_region}
   
2. Additional secrets to add:
   ECR_REPOSITORY: ${var.ecr_repository_name}
   ECS_CLUSTER: ${var.ecs_cluster_name}
   ECS_SERVICE: ${var.ecs_service_name}

3. Make sure your GitHub Actions workflow uses these secrets.
EOF
}