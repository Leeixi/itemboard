import json
import os
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
sns_client = boto3.client('sns')
ssm_client = boto3.client('ssm')

def handler(event, context):
    """
    Lambda function handler to:
    1. Process ECR push events from SQS
    2. Update EC2 instance with the latest Docker image
    3. Send notification about the update
    
    Parameters:
    - event: The event data from SQS
    - context: Lambda context object
    
    Returns:
    - Dictionary with status code and message
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    ec2_instance_id = os.environ.get('EC2_INSTANCE_ID')
    
    if not sns_topic_arn:
        logger.error("SNS_TOPIC_ARN environment variable not set")
        return error_response("SNS_TOPIC_ARN environment variable not set")
    
    if not ec2_instance_id:
        logger.error("EC2_INSTANCE_ID environment variable not set")
        return error_response("EC2_INSTANCE_ID environment variable not set")
    
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
                image_uri = f"{repository}:{image_tag}"
                timestamp = body.get('timestamp', 'unknown time')
                image_digest = body.get('imageDigest', 'unknown')
                
                # Update the EC2 instance with the new Docker image
                update_ec2_docker_container(
                    ec2_instance_id, 
                    f"471112562146.dkr.ecr.eu-central-1.amazonaws.com/{image_uri}"
                )
                
                # Create email subject and message
                subject = f"[{repository}] New image deployed: {image_tag}"
                message = (
                    f"New image deployed successfully!\n\n"
                    f"Repository: {repository}\n"
                    f"Image Tag: {image_tag}\n"
                    f"Image Digest: {image_digest}\n"
                    f"Timestamp: {timestamp}\n"
                    f"EC2 Instance: {ec2_instance_id}\n"
                    f"This notification was sent automatically by the ECR event notification system."
                )
            else:
                # Skip non-ECR messages
                logger.info("Skipping non-ECR event message")
                continue
            
            # Log what we're about to send
            logger.info(f"Preparing to send SNS message with subject: {subject}")
            
            # Send message to SNS topic
            logger.info(f"Sending message to SNS topic: {sns_topic_arn}")
            send_sns_message(sns_topic_arn, subject, message)
            logger.info("Message sent successfully")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Container updated and notification sent successfully'})
        }
    
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return error_response(f"Failed to process event: {str(e)}")

def update_ec2_docker_container(instance_id, image_uri):
    """
    Update Docker container on EC2 instance using SSM Run Command
    
    Parameters:
    - instance_id: EC2 instance ID
    - image_uri: Full ECR image URI to deploy
    
    Returns:
    - Dictionary with update status and output
    """
    try:
        # Command to login to ECR, pull the latest image, stop the existing container, and start a new one
        command = f"""#!/bin/bash
        # Login to ECR
        aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 471112562146.dkr.ecr.eu-central-1.amazonaws.com
        
        # Pull the latest image
        docker pull {image_uri}
        
        # Stop and remove any existing container
        docker stop itemboard || true
        docker rm itemboard || true
        
        # Run the new container
        docker run -d --name itemboard --network host -p 8000:8000 {image_uri}
        
        # Output status
        echo "Container updated successfully with image: {image_uri}"
        """
        
        # Execute command on the EC2 instance
        response = ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName='AWS-RunShellScript',
            Parameters={'commands': [command]},
            Comment='Update Docker container with latest image'
        )
        
        command_id = response['Command']['CommandId']
        logger.info(f"SSM Command sent. Command ID: {command_id}")
        
        # Wait for command to complete (you might want to implement a more robust waiting mechanism)
        import time
        time.sleep(10)
        
        # Get command output
        output = ssm_client.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id
        )
        
        return {
            'status': output['Status'],
            'output': output.get('StandardOutputContent', '')
        }
    
    except Exception as e:
        logger.error(f"Failed to update EC2 instance: {str(e)}")
        return {
            'status': 'Failed',
            'output': str(e)
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

def error_response(message):
    """
    Create an error response
    
    Parameters:
    - message: Error message
    
    Returns:
    - Dictionary with status code and error message
    """
    return {
        'statusCode': 500,
        'body': json.dumps({'error': message})
    }