# Get SQS queue ARN from the URL
data "aws_sqs_queue" "events_queue" {
  name = element(split("/", var.sqs_queue_url), length(split("/", var.sqs_queue_url)) - 1)
}

# Create SNS topic for email notifications
resource "aws_sns_topic" "email_notifications" {
  name = "${var.project_name}-notifications"
 
  tags = {
    Name    = "${var.project_name}-notifications"
    Project = var.project_name
  }
}

# Create email subscriptions to the SNS topic
resource "aws_sns_topic_subscription" "email_subscriptions" {
  count     = length(var.email_subscribers)
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = var.email_subscribers[count.index]
}

# Create IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-sqs-sns-lambda-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create policy for Lambda to read from SQS
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "${var.project_name}-lambda-sqs-policy"
  description = "Allow Lambda to receive messages from SQS"
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = data.aws_sqs_queue.events_queue.arn
      }
    ]
  })
}

# Create policy for Lambda to publish to SNS
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "${var.project_name}-lambda-sns-policy"
  description = "Allow Lambda to publish to SNS"
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.email_notifications.arn
      }
    ]
  })
}

# Attach SQS policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sqs_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# Attach SNS policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach SSM policy
resource "aws_iam_role_policy_attachment" "lambda_ssm_full_accesss" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Attach SSM policy
resource "aws_iam_role_policy_attachment" "lambda_ecr_readonly" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create Lambda function
resource "aws_lambda_function" "sqs_to_sns" {
  function_name    = "${var.project_name}-sqs-to-sns"
  role             = aws_iam_role.lambda_role.arn
  handler          = "itemboard-lambda.handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 128 # Minimal memory for simple processing
 
  filename         = "itemboard-lambda.zip"
  source_code_hash = filebase64sha256("itemboard-lambda.zip")
 
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.email_notifications.arn,
      EC2_INSTANCE_ID = var.EC2_INSTANCE_ID
    }
  }

}

# Create SQS event source mapping to trigger Lambda
resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  event_source_arn = data.aws_sqs_queue.events_queue.arn
  function_name    = aws_lambda_function.sqs_to_sns.function_name
  batch_size       = 10
}
