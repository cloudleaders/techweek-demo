# AWS-16 - Key Information Extract

## Core Requirements
- **Primary Goal**: Create DynamoDB table, SQS queue, and Lambda function integration
- **Trigger Flow**: DynamoDB changes → SQS queue → Lambda function
- **Lambda Action**: Print record values that were added/updated

## Technical Components
1. **DynamoDB Table**: Store data with change tracking
2. **SQS Queue**: Message queue for DynamoDB events
3. **Lambda Function**: Process messages and print record values
4. **DynamoDB Streams**: Capture table changes (implied)

## Business Logic
- Monitor DynamoDB table for record additions and updates
- Queue change events in SQS
- Lambda processes queued messages
- Output: Print values of changed records

## Key Integration Points
- DynamoDB → DynamoDB Streams → SQS
- SQS → Lambda (event-driven trigger)
- Lambda processing and logging

## Missing Details (Need Clarification)
- DynamoDB table schema/structure
- SQS queue configuration preferences
- Lambda runtime preference
- Output format for printed values
- Error handling requirements
- Scaling/performance requirements