# Changelog:
# AWS-14 - Unit tests for Lambda function - 2025-01-28

import json
import pytest
from unittest.mock import Mock, patch
import sys
import os

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src', 'lambda-python-s3-lambda-trigger'))

from lambda_handler import lambda_handler, process_s3_record

class TestLambdaHandler:
    """Test cases for S3 Lambda handler function."""
    
    def test_lambda_handler_success(self):
        """Test successful S3 event processing."""
        # Arrange
        event = {
            'Records': [
                {
                    'eventName': 'ObjectCreated:Put',
                    's3': {
                        'bucket': {'name': 'test-bucket'},
                        'object': {'key': 'test-file.txt', 'size': 1024}
                    }
                }
            ]
        }
        context = Mock()
        
        # Act
        result = lambda_handler(event, context)
        
        # Assert
        assert result['statusCode'] == 200
        body = json.loads(result['body'])
        assert body['message'] == 'S3 event processed successfully'
        assert body['processed_records'] == 1
    
    def test_lambda_handler_empty_event(self):
        """Test handler with empty event."""
        # Arrange
        event = {}
        context = Mock()
        
        # Act
        result = lambda_handler(event, context)
        
        # Assert
        assert result['statusCode'] == 200
        body = json.loads(result['body'])
        assert body['processed_records'] == 0
    
    def test_lambda_handler_error(self):
        """Test handler error handling."""
        # Arrange
        event = {'Records': [{'invalid': 'data'}]}
        context = Mock()
        
        # Act
        with patch('lambda_handler.process_s3_record', side_effect=Exception('Test error')):
            result = lambda_handler(event, context)
        
        # Assert
        assert result['statusCode'] == 500
        body = json.loads(result['body'])
        assert 'error' in body
    
    def test_process_s3_record_success(self):
        """Test S3 record processing."""
        # Arrange
        record = {
            'eventName': 'ObjectCreated:Put',
            's3': {
                'bucket': {'name': 'test-bucket'},
                'object': {'key': 'test-file.txt', 'size': 1024}
            }
        }
        
        # Act & Assert (should not raise exception)
        process_s3_record(record)
    
    def test_process_s3_record_missing_data(self):
        """Test S3 record processing with missing data."""
        # Arrange
        record = {}
        
        # Act & Assert (should not raise exception)
        process_s3_record(record)