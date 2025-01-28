#!/bin/bash

# Purpose: Updates the "coupons_import" Lambda function in LocalStack.
#          Ensures it accepts events from the /coupons/import API Gateway endpoint and
#          saves coupon files in S3 in JSON format with the filename <coupon_id>.json.

ENDPOINT_URL="http://localhost:4566"
FUNCTION_NAME="coupons_import"
ZIP_FILE_PATH="./dist/coupons_import.zip"  # Adjust to your build artifact

# 1. Update the Lambda function code
aws --endpoint-url="$ENDPOINT_URL" lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$ZIP_FILE_PATH"

echo "Updated Lambda function code for '$FUNCTION_NAME'."

# 2. (Optional) Update Lambda function configuration if needed
# For example, environment variables or handler
# aws --endpoint-url="$ENDPOINT_URL" lambda update-function-configuration ...

