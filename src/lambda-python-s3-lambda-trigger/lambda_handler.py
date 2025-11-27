# Changelog:
# AWS-14 - Initial Lambda function for S3 event processing - 2025-01-28

import json
import logging
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda function handler for S3 event processing.
    
    Args:
        event: S3 event data containing bucket and object information
        context: Lambda context object
        
    Returns:
        Dict containing response data
    """
    try:
        logger.info(f"Received S3 event with {len(event.get('Records', []))} records")
        
        # Process each S3 record in the event
        for record in event.get('Records', []):
            try:
                process_s3_record(record)
            except Exception as record_error:
                logger.error(f"Failed to process record: {str(record_error)}")
                # Continue processing other records
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'S3 event processed successfully',
                'processed_records': len(event.get('Records', []))
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }

def process_s3_record(record: Dict[str, Any]) -> None:
    """
    Process individual S3 record from the event.
    
    Args:
        record: Individual S3 record containing event details
    """
    try:
        # Extract S3 event information
        event_name = record.get('eventName', 'Unknown')
        bucket_name = record.get('s3', {}).get('bucket', {}).get('name', 'Unknown')
        object_key = record.get('s3', {}).get('object', {}).get('key', 'Unknown')
        object_size = record.get('s3', {}).get('object', {}).get('size', 0)
        
        # Log the S3 event details
        logger.info(f"Processing S3 event - Event: {event_name}, Bucket: {bucket_name}, Object: {object_key}, Size: {object_size} bytes")
        
        # Demo processing - log file operation details
        if 'ObjectCreated' in event_name:
            logger.info(f"File uploaded successfully: {object_key} ({object_size} bytes)")
        elif 'ObjectRemoved' in event_name:
            logger.info(f"File deleted successfully: {object_key}")
        
    except Exception as e:
        logger.error(f"Error processing S3 record for bucket {bucket_name}, object {object_key}: {str(e)}")
        raise Exception(f"Failed to process S3 record for bucket {bucket_name}, object {object_key}") from e