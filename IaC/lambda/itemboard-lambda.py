import json
import os
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
sns_client = boto3.client('sns')

def handler(event, context):
    """
    Lambda function handler to process messages from SQS and send them via SNS.
    
    Parameters:
    - event: The event data from SQS
    - context: Lambda context object
    
    Returns:
    - Dictionary with status code and message
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    if not sns_topic_arn:
        logger.error("SNS_TOPIC_ARN environment variable not set")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'SNS_TOPIC_ARN environment variable not set'})
        }
    
    try:
        # Process each record from SQS
        for record in event.get('Records', []):
            # Parse the message body
            try:
                body = json.loads(record.get('body', '{}'))
                logger.info(f"Parsed message body: {json.dumps(body)}")
            except json.JSONDecodeError:
                # If not JSON, use the raw body
                body = record.get('body', '{}')
                logger.info(f"Using raw message body: {body}")
            
            # For ECR events, extract relevant information
            if isinstance(body, dict) and 'repository' in body:
                repository = body.get('repository', 'unknown')
                image_tag = body.get('imageTag', 'latest')
                timestamp = body.get('timestamp', 'unknown time')
                image_digest = body.get('imageDigest', 'unknown')
                
                # Create email subject and message
                subject = f"[{repository}] New image pushed: {image_tag}"
                message = (
                    f"New image push detected!\n\n"
                    f"Repository: {repository}\n"
                    f"Image Tag: {image_tag}\n"
                    f"Image Digest: {image_digest}\n"
                    f"Timestamp: {timestamp}\n\n"
                    f"This notification was sent automatically by the ECR event notification system."
                )
            else:
                # For service push events or other message types
                subject = "Deployment Notification"
                
                if isinstance(body, dict):
                    # Try to extract service information if available
                    service = body.get('service', body.get('serviceName', 'unknown service'))
                    status = body.get('status', 'deployed')
                    message = f"Service '{service}' has been {status}.\n\nFull details: {json.dumps(body, indent=2)}"
                else:
                    # Generic message for non-JSON or unexpected format
                    message = f"Received deployment notification:\n\n{body}"
            
            # Log what we're about to send
            logger.info(f"Preparing to send SNS message with subject: {subject}")
            
            # Send message to SNS topic
            logger.info(f"Sending message to SNS topic: {sns_topic_arn}")
            send_sns_message(sns_topic_arn, subject, message)
            logger.info("Message sent successfully")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Notification sent successfully'})
        }
    
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Failed to process event: {str(e)}'})
        }

def send_sns_message(topic_arn, subject, message):
    """
    Send a message to an SNS topic.
    
    Parameters:
    - topic_arn: The ARN of the SNS topic
    - subject: Email subject
    - message: Email message body
    
    Returns:
    - None
    """
    try:
        response = sns_client.publish(
            TopicArn=topic_arn,
            Subject=subject,
            Message=message
        )
        logger.info(f"Message published to SNS. Message ID: {response['MessageId']}")
    except Exception as e:
        logger.error(f"Failed to publish message to SNS: {str(e)}")
        raise e