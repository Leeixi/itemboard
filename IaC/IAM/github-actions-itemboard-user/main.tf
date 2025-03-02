provider "aws" {
  region = var.aws_region
}

# IAM User for GitHub Actions
resource "aws_iam_user" "github_actions" {
  name = "github-actions-${var.project_name}"

  tags = {
    Description = "IAM user for GitHub Actions CI/CD pipeline"
    Project     = var.project_name
  }
}

# Custom policy for GitHub Actions
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-${var.project_name}-policy"
  description = "Policy for GitHub Actions to manage ECR and ECS resources"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTasks"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeClusters"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the user
resource "aws_iam_policy_attachment" "github_actions_user_policy_attachemnt" {
  name       = "github_actions_user_policy_attachemnt"
  users      = [ aws_iam_user.github_actions.name ]
  policy_arn = aws_iam_policy.github_actions.arn
  depends_on = [ aws_iam_policy.github_actions ]
}
