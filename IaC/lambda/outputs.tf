
# Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.sqs_to_sns.function_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.email_notifications.arn
}

output "subscribed_emails" {
  description = "Email addresses subscribed to notifications"
  value       = var.email_subscribers
}