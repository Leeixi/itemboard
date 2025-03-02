# Outputs
output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.ecr_events_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.ecr_events_queue.arn
}

output "event_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.ecr_image_push.arn
}
