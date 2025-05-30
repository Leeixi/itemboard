provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "itemboard"
}
# Enter SQS and email_subscribers
variable "sqs_queue_url" {
  description = "URL of the SQS queue to monitor"
  type        = string
  default     = "https://sqs.eu-central-1.amazonaws.com/471112562146/itemboard-ecr-events-queue"
}

variable "email_subscribers" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default     = ["david.levacicc@gmail.com"]
}

variable "lambda_filename" {
  description = "Name of ZIP file which contains Lambda code"
  type        = string
  default     = "itemboard-deploy-lambda.zip"
}

variable "EC2_INSTANCE_ID" {
  description = "EC2 instance where we deploy docker image"
  type        = string
  default     = "i-00e8b14774ea3e887"
}