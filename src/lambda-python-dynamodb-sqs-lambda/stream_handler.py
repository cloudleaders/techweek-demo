# Changelog:
# AWS-16 - Stream processor Lambda for DynamoDB to SQS - 2025-01-28

import json
import boto3
import logging
import os
from typing import Dict, Any

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SQS client at module level for performance
sqs = boto3.client('sqs')

QUEUE_URL = os.environ.get('QUEUE_URL')
if not QUEUE_URL:
    raise ValueError("QUEUE_URL environment variable is required")

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Process DynamoDB stream events and send to SQS.
    """
    try:
        processed_records = 0
        failed_records = []
        
        for record in event.get('Records', []):
            try:
                # Send DynamoDB stream record to SQS
                message_body = json.dumps(record)
                
                sqs.send_message(
                    QueueUrl=QUEUE_URL,
                    MessageBody=message_body
                )
                
                processed_records += 1
                event_name = record.get('eventName', 'UNKNOWN')
                event_source = record.get('eventSource', 'UNKNOWN')
                logger.info(f"Sent record to SQS: {event_name} from {event_source}")
                
            except Exception as e:
                logger.error(f"Error processing stream record: {str(e)}")
                failed_records.append(record)
        
        # For DynamoDB streams, if any record fails, the entire batch should fail
        if failed_records:
            raise Exception(f"Failed to process {len(failed_records)} records")
                
        logger.info(f"Successfully processed {processed_records} stream records")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'processed_count': processed_records})
        }
        
    except Exception as e:
        logger.error(f"Error in stream handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }