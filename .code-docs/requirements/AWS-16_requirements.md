# Technical Requirements Specification

## Document Information

- **Ticket Number**: AWS-16
- **Ticket Title**: I want to create a dynamodb table, sqs queue and a lambda function
- **Created Date**: 2025-12-03T17:25:56.250+0530
- **Last Updated**: 2025-01-28T14:35:00Z
- **Status**: To Do

## 1. Project Overview

**Business Objective**: Demonstrate event-driven architecture using AWS managed services for real-time data processing and notification.

**Solution Summary**: Create an integrated system where DynamoDB table changes automatically trigger SQS messages, which are then processed by Lambda functions to log and display record modifications.

**Scope**: Implementation includes DynamoDB table with streams, SQS queue, Lambda function, and necessary IAM roles. Out of scope: UI components, external integrations, advanced error handling beyond basic retry mechanisms.

## 2. Functional Requirements

### 2.1 Core Functionality

- **FR-1**: DynamoDB table must capture and store data records with automatic change detection
- **FR-2**: DynamoDB Streams must capture all INSERT and MODIFY operations on the table
- **FR-3**: SQS queue must receive and store change events from DynamoDB Streams
- **FR-4**: Lambda function must process SQS messages and print/log record values

### 2.2 User Interactions

- **UI-1**: Manual data insertion/update via AWS Console or API calls for testing
- **API-1**: DynamoDB PutItem/UpdateItem operations trigger the workflow
- **Data-1**: Lambda function outputs processed record data to CloudWatch Logs

### 2.3 Data Requirements

**Data Input**: JSON records inserted/updated in DynamoDB table

**Data Processing**: DynamoDB Streams capture changes → SQS message formatting → Lambda processing

**Data Output**: Formatted log output showing original and modified record values

**Data Volume**: Demo-level volume (< 100 records/minute for testing)

## 3. Non-Functional Requirements

### 3.1 Performance

- **Response Time**: DynamoDB operations < 100ms, Lambda processing < 5 seconds
- **Throughput**: Support up to 100 concurrent record modifications
- **Scalability**: Auto-scaling enabled for Lambda concurrent executions

### 3.2 Security

- **Authentication**: IAM roles with least privilege access
- **Authorization**: Lambda execution role with DynamoDB read, SQS receive/delete permissions
- **Data Protection**: Encryption at rest for DynamoDB, encryption in transit for SQS
- **Audit**: CloudWatch logging for all Lambda executions and errors

### 3.3 Reliability

- **Availability**: 99.9% uptime using AWS managed services
- **Disaster Recovery**: Multi-AZ deployment for DynamoDB and SQS
- **Backup**: DynamoDB point-in-time recovery enabled

### 3.4 Operational

- **Monitoring**: CloudWatch metrics for DynamoDB, SQS, and Lambda
- **Logging**: Structured logging in Lambda with correlation IDs
- **Alerting**: CloudWatch alarms for Lambda errors and SQS dead letter queue

## 4. Technical Specifications

### 4.1 Architecture

**Architecture Approach**: Event-driven serverless architecture using AWS managed services.

**Architecture Diagram**: Visual representation of the AWS architecture:

![Architecture Diagram](./AWS-16-architecture-diagram.png)

**Figure 1: AWS Event-Driven Architecture Diagram**

**Technology Stack**: 
- **Database**: DynamoDB with Streams
- **Messaging**: SQS Standard Queue
- **Compute**: Lambda (Python 3.12)
- **Monitoring**: CloudWatch Logs and Metrics

### 4.2 AWS Services

- **Compute**: Lambda functions for event processing
- **Storage**: DynamoDB table with streams enabled
- **Messaging**: SQS queue for reliable message delivery
- **Security**: IAM roles and policies for service permissions
- **Monitoring**: CloudWatch for logging, metrics, and alarms

### 4.3 Integration Points

**External Systems**: None (self-contained demo system)

**API Contracts**: 
- DynamoDB API for data operations
- SQS API for message processing
- Lambda event interface for SQS triggers

**Data Formats**: JSON for DynamoDB records and SQS messages

### 4.4 Environment Requirements

- **Environments**: Development environment for demonstration
- **Deployment**: Infrastructure as Code using Terraform or CloudFormation

## 5. Acceptance Criteria

### 5.1 Functional Acceptance

- [ ] DynamoDB table created with streams enabled
- [ ] SQS queue receives messages when DynamoDB records change
- [ ] Lambda function processes SQS messages successfully
- [ ] Lambda outputs record values to CloudWatch Logs
- [ ] End-to-end workflow completes within 10 seconds

### 5.2 Non-Functional Acceptance

- [ ] All AWS resources deployed with proper IAM permissions
- [ ] CloudWatch monitoring configured for all services
- [ ] Error handling implemented with dead letter queue
- [ ] Documentation includes deployment and testing instructions

## 6. Dependencies

### 6.1 Technical Dependencies

- **Other JIRA Tickets**: None identified
- **External Services**: AWS account with appropriate service limits
- **Infrastructure**: AWS region with DynamoDB, SQS, and Lambda availability

### 6.2 Team Dependencies

- **Other Teams**: None required for this demonstration
- **Coordination**: Self-contained implementation

## 7. Assumptions

Document key assumptions made during requirements gathering (after clarification):

- DynamoDB table schema: "id" (string) as partition key, "name" and "email" as string attributes
- Lambda output format: Plain text logging to CloudWatch
- Event handling: Process INSERT, UPDATE, and DELETE operations
- Error handling: 3 retry attempts before failure
- AWS deployment region: us-east-1
- Resource naming: "techweek-demo" prefix for all AWS resources
- No cleanup scripts required for demo environment

## 8. Risks

- **RISK-1**: DynamoDB Streams may have delay in change detection
  - **Impact**: Medium
  - **Mitigation**: Implement retry logic and monitoring for stream lag

- **RISK-2**: SQS message processing failures could cause data loss
  - **Impact**: High
  - **Mitigation**: Configure dead letter queue and implement error handling

- **RISK-3**: Lambda cold starts may affect processing time
  - **Impact**: Low
  - **Mitigation**: Use provisioned concurrency if consistent performance required

## 9. Open Questions

> **CRITICAL**: This section is **MANDATORY** for identifying ambiguities. All missing or unclear information must be documented here using the format shown below. Requirements approval should not proceed until all blocking questions have `[Answer]:` filled in.

1. What should be the DynamoDB table schema (partition key, sort key, attributes)?
   [Answer]: "id" as partition key, simple string attributes for name and email 

2. What specific record values should the Lambda function print (all attributes or specific ones)?
   [Answer]: all attributes

3. Should the Lambda function print both old and new values for UPDATE operations?
   [Answer]: Lambda function should print both old and new values

4. What format should the Lambda output use (JSON, plain text, structured logging)?
   [Answer]: plain text

5. Should there be any filtering of DynamoDB events (e.g., only certain attribute changes)?
   [Answer]: nothing

6. What should happen if Lambda processing fails - retry count and dead letter queue configuration?
   [Answer]: retry for 3 times then fail for now

7. Should the system handle DELETE operations from DynamoDB or only INSERT/UPDATE?
   [Answer]: Yes system should handle delete operation as well

8. What AWS region should be used for deployment?
   [Answer]: us-east-1

9. Are there any specific naming conventions for AWS resources?
   [Answer]: use techweek-demo prefix

10. Should the solution include cleanup/teardown scripts for demo purposes?
    [Answer]: No