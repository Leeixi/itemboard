# Create SQS queue for ECR events
resource "aws_sqs_queue" "ecr_events_queue" {
  name                      = "${var.project_name}-ecr-events-queue"
  delay_seconds             = 0
  max_message_size          = 262144  # 256 KB
  message_retention_seconds = 86400   # 1 day
  receive_wait_time_seconds = 10      # Long polling

  tags = {
    Name    = "${var.project_name}-ecr-events-queue"
    Project = var.project_name
  }
}

# Create a dead-letter queue for failed messages
resource "aws_sqs_queue" "ecr_events_dlq" {
  name                      = "${var.project_name}-ecr-events-dlq"
  message_retention_seconds = 1209600  # 14 days
  
  tags = {
    Name    = "${var.project_name}-ecr-events-dlq"
    Project = var.project_name
  }
}

# Configure the main queue to use the DLQ
resource "aws_sqs_queue_redrive_policy" "ecr_events_redrive" {
  queue_url = aws_sqs_queue.ecr_events_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ecr_events_dlq.arn
    maxReceiveCount     = 5
  })
}

# Create IAM role for EventBridge to SQS
resource "aws_iam_role" "events_role" {
  name = "${var.project_name}-events-to-sqs-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# Create policy for EventBridge to send messages to SQS
resource "aws_iam_policy" "events_sqs_policy" {
  name        = "${var.project_name}-events-to-sqs-policy"
  description = "Allow EventBridge to send messages to SQS"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.ecr_events_queue.arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "events_sqs_policy_attachment" {
  role       = aws_iam_role.events_role.name
  policy_arn = aws_iam_policy.events_sqs_policy.arn
}

# Create EventBridge rule to capture ECR image push events
resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  name        = "${var.project_name}-ecr-image-push"
  description = "Capture ECR image push events"
  
  event_pattern = jsonencode({
    source      = ["aws.ecr"],
    detail-type = ["ECR Image Action"],
    detail      = {
      action-type = ["PUSH"],
      repository-name = [var.ecr_repository_name]
    }
  })
}

# Set SQS queue as target for the EventBridge rule
resource "aws_cloudwatch_event_target" "ecr_image_push_target" {
  rule      = aws_cloudwatch_event_rule.ecr_image_push.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.ecr_events_queue.arn
  role_arn  = aws_iam_role.events_role.arn
  
  # Transform the event to include only relevant information
  input_transformer {
    input_paths = {
      image_digest  = "$.detail.image-digest",
      image_tag     = "$.detail.image-tag",
      repository    = "$.detail.repository-name",
      time          = "$.time",
      account       = "$.account"
    }
    input_template = <<EOF
{
  "imageDigest": <image_digest>,
  "imageTag": <image_tag>,
  "repository": <repository>,
  "timestamp": <time>,
  "accountId": <account>
}
EOF
  }
}