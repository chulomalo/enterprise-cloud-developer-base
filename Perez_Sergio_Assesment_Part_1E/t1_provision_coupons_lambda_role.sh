#!/bin/bash

# Create the IAM Role
aws --endpoint-url=$ENDPOINT_URL iam create-role \
  --role-name coupons_lambda_role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach CloudWatch Policy for logging
aws --endpoint-url=$ENDPOINT_URL iam put-role-policy \
  --role-name coupons_lambda_role \
  --policy-name CouponsCloudWatchPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:us-east-1:000000000000:log-group:/aws/lambda/coupons*"
      }
    ]
  }'

# Attach DynamoDB Policy for table access
aws --endpoint-url=$ENDPOINT_URL iam put-role-policy \
  --role-name coupons_lambda_role \
  --policy-name CouponsDynamoDBPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ],
        "Resource": "arn:aws:dynamodb:us-east-1:000000000000:table/coupons"
      }
    ]
  }'

echo "IAM Role coupons_lambda_role created successfully"

