# Changelog:
# AWS-14 - Initial Lambda function for S3 trigger - 2025-01-27

import json
import logging
from typing import Dict, Any

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda function triggered by S3 file uploads.
    
    Args:
        event: S3 event data
        context: Lambda context object
        
    Returns:
        Dict containing response data
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        for record in event.get('Records', []):
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            event_name = record['eventName']
            
            logger.info(f"File uploaded: {object_key} to bucket: {bucket_name}")
            logger.info(f"Event: {event_name}")
            
            # Process the uploaded file
            process_file(bucket_name, object_key)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File processing completed successfully',
                'processed_files': len(event.get('Records', []))
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }

def process_file(bucket_name: str, object_key: str) -> None:
    """
    Process the uploaded file.
    
    Args:
        bucket_name: S3 bucket name
        object_key: S3 object key
    """
    logger.info(f"Processing file: {object_key} from bucket: {bucket_name}")
    
    # Demo processing - log file details
    file_info = {
        'bucket': bucket_name,
        'key': object_key,
        'message': 'File successfully processed by Lambda function'
    }
    
    logger.info(f"File processing result: {json.dumps(file_info)}")