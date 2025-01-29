#!/bin/bash

ROLE_NAME="coupons_lambda_role"
POLICY_NAME="coupons_lambda_role_policy"

echo "Creating IAM role: $ROLE_NAME"

# 1. Create the IAM Role with a trust policy for Lambda
awslocal iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://assume_role_policy.json
[ $? -eq 0 ] && echo "Role $ROLE_NAME created successfully."

echo "Attaching inline policy to restrict CloudWatch logs and DynamoDB to 'coupons' table"

# 2. Attach policy that:
#    - Allows logs:* for log groups named '/aws/lambda/coupons*'
#    - Allows dynamodb:* for the 'coupons' table only
awslocal iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name $POLICY_NAME \
  --policy-document file://coupons_lambda_role_policy.json
[ $? -eq 0 ] && echo "Policy $POLICY_NAME attached successfully."

