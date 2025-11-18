# Changelog:
# AWS-14 - Unit tests for file processor Lambda function - 2025-01-27

import json
import pytest
from unittest.mock import patch, MagicMock
import sys
import os

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src', 'lambda-file-processor'))

from lambda_handler import lambda_handler, process_file

class TestLambdaHandler:
    """Test cases for Lambda handler function."""
    
    def test_lambda_handler_success(self):
        """Test successful file processing."""
        # Mock S3 event
        event = {
            'Records': [
                {
                    's3': {
                        'bucket': {'name': 'test-bucket'},
                        'object': {'key': 'test-file.txt'}
                    }
                }
            ]
        }
        
        context = MagicMock()
        
        # Mock S3 client
        with patch('lambda_handler.s3_client') as mock_s3:
            mock_s3.head_object.return_value = {
                'ContentLength': 1024,
                'ContentType': 'text/plain'
            }
            
            result = lambda_handler(event, context)
            
            assert result['statusCode'] == 200
            body = json.loads(result['body'])
            assert body['message'] == 'File processing completed successfully'
            assert body['processed_files'] == 1
    
    def test_lambda_handler_error(self):
        """Test error handling in Lambda function."""
        # Invalid event structure
        event = {'invalid': 'event'}
        context = MagicMock()
        
        result = lambda_handler(event, context)
        
        assert result['statusCode'] == 500
        body = json.loads(result['body'])
        assert body['error'] == 'File processing failed'

class TestProcessFile:
    """Test cases for file processing function."""
    
    def test_process_file_success(self):
        """Test successful file processing."""
        result = process_file('test-bucket', 'test-file.txt', 1024, 'text/plain')
        
        assert result['status'] == 'success'
        assert result['message'] == 'File processed successfully'
        assert result['file_info']['size'] == 1024
        assert result['validation']['is_allowed_type'] == True
    
    def test_process_file_empty(self):
        """Test processing empty file."""
        result = process_file('test-bucket', 'empty-file.txt', 0, 'text/plain')
        
        assert result['status'] == 'warning'
        assert result['message'] == 'Empty file detected'
        assert result['validation']['is_empty'] == True
    
    def test_process_file_unsupported_type(self):
        """Test processing unsupported file type."""
        result = process_file('test-bucket', 'test-file.exe', 1024, 'application/x-executable')
        
        assert result['status'] == 'success'
        assert result['validation']['is_allowed_type'] == False
    
    def test_process_file_allowed_types(self):
        """Test various allowed file types."""
        test_cases = [
            ('image/jpeg', True),
            ('text/plain', True),
            ('application/pdf', True),
            ('application/json', True),
            ('video/mp4', False),
            ('application/x-executable', False)
        ]
        
        for content_type, expected_allowed in test_cases:
            result = process_file('test-bucket', 'test-file', 1024, content_type)
            assert result['validation']['is_allowed_type'] == expected_allowed

if __name__ == '__main__':
    pytest.main([__file__])