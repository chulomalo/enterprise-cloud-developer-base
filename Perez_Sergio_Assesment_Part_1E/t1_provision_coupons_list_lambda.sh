#!/bin/bash

# Package Lambda Function Code
zip coupons_list.zip coupons_list.py

# Create Lambda Function
aws --endpoint-url=$ENDPOINT_URL lambda create-function \
  --function-name coupons_list \
  --runtime python3.9 \
  --role arn:aws:iam::000000000000:role/coupons_lambda_role \
  --handler coupons_list.lambda_handler \
  --zip-file fileb://coupons_list.zip

echo "Lambda Function coupons_list created successfully"

