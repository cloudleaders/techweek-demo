import json
import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'src', 'lambda-python-dynamodb-sqs-lambda'))

from lambda_handler import lambda_handler, process_dynamodb_change, log_dynamodb_item

def test_lambda_handler_success():
    """Test successful processing of SQS records."""
    event = {
        'Records': [
            {
                'body': json.dumps({
                    'eventName': 'INSERT',
                    'dynamodb': {
                        'NewImage': {
                            'id': {'S': 'test-id'},
                            'name': {'S': 'Test User'},
                            'email': {'S': 'test@example.com'}
                        }
                    }
                })
            }
        ]
    }
    
    context = Mock()
    
    result = lambda_handler(event, context)
    
    assert result['statusCode'] == 200
    body = json.loads(result['body'])
    assert body['processed_count'] == 1

def test_lambda_handler_empty_records():
    """Test handling of empty records."""
    event = {'Records': []}
    context = Mock()
    
    result = lambda_handler(event, context)
    
    assert result['statusCode'] == 200
    body = json.loads(result['body'])
    assert body['processed_count'] == 0

def test_process_dynamodb_change_insert():
    """Test processing INSERT event."""
    change_event = {
        'eventName': 'INSERT',
        'dynamodb': {
            'NewImage': {
                'id': {'S': 'test-id'},
                'name': {'S': 'Test User'}
            }
        }
    }
    
    with patch('lambda_handler.logger') as mock_logger:
        process_dynamodb_change(change_event)
        mock_logger.info.assert_called()

def test_process_dynamodb_change_modify():
    """Test processing MODIFY event."""
    change_event = {
        'eventName': 'MODIFY',
        'dynamodb': {
            'OldImage': {
                'id': {'S': 'test-id'},
                'name': {'S': 'Old Name'}
            },
            'NewImage': {
                'id': {'S': 'test-id'},
                'name': {'S': 'New Name'}
            }
        }
    }
    
    with patch('lambda_handler.logger') as mock_logger:
        process_dynamodb_change(change_event)
        mock_logger.info.assert_called()

def test_process_dynamodb_change_remove():
    """Test processing REMOVE event."""
    change_event = {
        'eventName': 'REMOVE',
        'dynamodb': {
            'OldImage': {
                'id': {'S': 'test-id'},
                'name': {'S': 'Deleted User'}
            }
        }
    }
    
    with patch('lambda_handler.logger') as mock_logger:
        process_dynamodb_change(change_event)
        mock_logger.info.assert_called()

def test_log_dynamodb_item():
    """Test logging DynamoDB item."""
    item = {
        'id': {'S': 'test-id'},
        'name': {'S': 'Test User'},
        'count': {'N': '42'}
    }
    
    with patch('lambda_handler.logger') as mock_logger:
        log_dynamodb_item(item, "Test Item")
        mock_logger.info.assert_called()

def test_log_dynamodb_item_empty():
    """Test logging empty DynamoDB item."""
    with patch('lambda_handler.logger') as mock_logger:
        log_dynamodb_item({}, "Empty Item")
        mock_logger.info.assert_called_with("Empty Item: No data")