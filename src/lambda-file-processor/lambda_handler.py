# Changelog:
# AWS-14 - Initial Lambda function for S3 file processing - 2025-01-27

import json
import logging
import boto3
from typing import Dict, Any
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda function to process files uploaded to S3 bucket.
    
    Args:
        event: S3 event data containing bucket and object information
        context: Lambda context object
        
    Returns:
        Dict containing processing results
    """
    try:
        # Process each record in the event
        for record in event['Records']:
            # Extract S3 bucket and object information
            bucket_name = record['s3']['bucket']['name']
            object_key = unquote_plus(record['s3']['object']['key'])
            
            logger.info(f"Processing file: {object_key} from bucket: {bucket_name}")
            
            # Get object metadata
            response = s3_client.head_object(Bucket=bucket_name, Key=object_key)
            file_size = response['ContentLength']
            content_type = response.get('ContentType', 'unknown')
            
            # Process the file
            result = process_file(bucket_name, object_key, file_size, content_type)
            
            logger.info(f"File processing completed: {json.dumps(result)}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File processing completed successfully',
                'processed_files': len(event['Records'])
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'File processing failed',
                'message': str(e)
            })
        }

def process_file(bucket_name: str, object_key: str, file_size: int, content_type: str) -> Dict[str, Any]:
    """
    Process individual file from S3 bucket.
    
    Args:
        bucket_name: Name of the S3 bucket
        object_key: Key of the S3 object
        file_size: Size of the file in bytes
        content_type: MIME type of the file
        
    Returns:
        Dict containing processing results
    """
    try:
        # Basic file validation
        if file_size == 0:
            logger.warning(f"Empty file detected: {object_key}")
            return {
                'status': 'warning',
                'message': 'Empty file detected',
                'file_info': {
                    'bucket': bucket_name,
                    'key': object_key,
                    'size': file_size,
                    'content_type': content_type
                }
            }
        
        # Log file details
        file_info = {
            'bucket': bucket_name,
            'key': object_key,
            'size': file_size,
            'content_type': content_type,
            'size_mb': round(file_size / (1024 * 1024), 2)
        }
        
        logger.info(f"File details: {json.dumps(file_info)}")
        
        # Basic file type validation
        allowed_types = ['image/', 'text/', 'application/pdf', 'application/json']
        is_allowed_type = any(content_type.startswith(allowed) for allowed in allowed_types)
        
        if not is_allowed_type:
            logger.warning(f"Unsupported file type: {content_type}")
        
        return {
            'status': 'success',
            'message': 'File processed successfully',
            'file_info': file_info,
            'validation': {
                'is_allowed_type': is_allowed_type,
                'is_empty': file_size == 0
            }
        }
        
    except Exception as e:
        logger.error(f"Error processing file {object_key}: {str(e)}")
        return {
            'status': 'error',
            'message': f'File processing failed: {str(e)}',
            'file_info': {
                'bucket': bucket_name,
                'key': object_key
            }
        }