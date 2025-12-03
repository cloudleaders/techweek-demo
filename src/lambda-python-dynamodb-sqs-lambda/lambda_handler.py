# Changelog:
# AWS-16 - Initial Lambda function for SQS message processing - 2025-01-28

import json
import logging
from typing import Dict, Any

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Process SQS messages containing DynamoDB change events.
    """
    try:
        processed_records = 0
        failed_records = []
        
        for record in event.get('Records', []):
            try:
                message_body = json.loads(record['body'])
                process_dynamodb_change(message_body)
                processed_records += 1
                
            except Exception as e:
                logger.error(f"Error processing record: {str(e)}")
                failed_records.append(record)
                
        logger.info(f"Successfully processed {processed_records} records, {len(failed_records)} failed")
        
        # Return batch item failures for SQS partial retry
        response = {
            'statusCode': 200,
            'body': json.dumps({
                'processed_count': processed_records,
                'failed_count': len(failed_records)
            })
        }
        
        if failed_records:
            response['batchItemFailures'] = [
                {'itemIdentifier': record.get('messageId', '')} 
                for record in failed_records
            ]
            
        return response
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }

def process_dynamodb_change(change_event: Dict[str, Any]) -> None:
    """Process DynamoDB change event and log in plain text."""
    try:
        event_name = change_event.get('eventName', 'UNKNOWN')
        
        logger.info(f"=== DynamoDB Change Event: {event_name} ===")
        
        if event_name == 'INSERT':
            new_image = change_event.get('dynamodb', {}).get('NewImage', {})
            logger.info("INSERT Operation:")
            log_dynamodb_item(new_image, "New Record")
            
        elif event_name == 'MODIFY':
            old_image = change_event.get('dynamodb', {}).get('OldImage', {})
            new_image = change_event.get('dynamodb', {}).get('NewImage', {})
            logger.info("UPDATE Operation:")
            log_dynamodb_item(old_image, "Old Values")
            log_dynamodb_item(new_image, "New Values")
            
        elif event_name == 'REMOVE':
            old_image = change_event.get('dynamodb', {}).get('OldImage', {})
            logger.info("DELETE Operation:")
            log_dynamodb_item(old_image, "Deleted Record")
            
        logger.info("=== End of Change Event ===")
        
    except Exception as e:
        logger.error(f"Error processing DynamoDB change: {str(e)}")

def log_dynamodb_item(item: Dict[str, Any], label: str) -> None:
    """Log DynamoDB item attributes in plain text format."""
    if not item:
        logger.info(f"{label}: No data")
        return
        
    logger.info(f"{label}:")
    
    for attr_name, attr_value in item.items():
        try:
            # Sanitize sensitive data
            if attr_name.lower() in ['password', 'secret', 'token', 'key']:
                value = "[REDACTED]"
            elif 'S' in attr_value:
                value = attr_value['S']
            elif 'N' in attr_value:
                value = attr_value['N']
            elif 'BOOL' in attr_value:
                value = str(attr_value['BOOL'])
            elif 'L' in attr_value:
                value = f"[List with {len(attr_value['L'])} items]"
            elif 'M' in attr_value:
                value = f"[Map with {len(attr_value['M'])} keys]"
            elif 'SS' in attr_value:
                value = f"[String Set: {', '.join(attr_value['SS'])}]"
            elif 'NS' in attr_value:
                value = f"[Number Set: {', '.join(attr_value['NS'])}]"
            elif 'B' in attr_value:
                value = f"[Binary: {len(attr_value['B'])} bytes]"
            else:
                value = str(attr_value)
                
            logger.info(f"  {attr_name}: {value}")
        except Exception as e:
            logger.error(f"  {attr_name}: [Error processing attribute: {str(e)}]")
            continue