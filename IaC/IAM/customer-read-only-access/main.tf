# IAM User for Customer
resource "aws_iam_user" "customer_access" {
  name = "customer-${var.project_name}"
  
  tags = {
    "Description" = "IAM user for Customer with read-only and billing access"
    "Project" = var.project_name
  }
}

# Create login profile with password reset required
resource "aws_iam_user_login_profile" "customer_access" {
  user = aws_iam_user.customer_access.name
  password_length = 16
  password_reset_required = true
}

# Create custom policy for console access
resource "aws_iam_policy" "console-access" {
  name = "console-access-${var.project_name}"
  description = "Policy for console access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ChangePassword",
          "iam:GetUser"
        ]
        Effect = "Allow"
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      }
    ]
  })
}

# Create billing access policy
resource "aws_iam_policy" "billing-access" {
  name        = "billing-access-${var.project_name}"
  description = "Policy for billing access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "aws-portal:ViewBilling",
          "aws-portal:ViewUsage",
          "aws-portal:ViewAccount",
          "aws-portal:ViewPaymentMethods",
          "budgets:ViewBudget",
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetUsageForecast",
          "ce:GetReservationUtilization",
          "ce:GetDimensionValues",
          "ce:GetTags",
          "ce:GetCostCategories",
          "pricing:GetProducts"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach ReadOnlyAccess policy to the user
resource "aws_iam_user_policy_attachment" "customer_access-readonly" {
  user = aws_iam_user.customer_access.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Attach console access policy to the user
resource "aws_iam_user_policy_attachment" "customer-console-access" {
  user = aws_iam_user.customer_access.name
  policy_arn = aws_iam_policy.console-access.arn
}

# Attach billing access policy to the user
resource "aws_iam_user_policy_attachment" "customer-billing-access" {
  user = aws_iam_user.customer_access.name
  policy_arn = aws_iam_policy.billing-access.arn
}