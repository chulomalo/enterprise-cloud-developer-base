#!/bin/bash

# Purpose: Updates the "coupons_import_presigned_url" Lambda function in LocalStack.
#          Ensures it returns a pre-signed URL for uploading a specific file to the "coupons" bucket.

ENDPOINT_URL="http://localhost:4566"
FUNCTION_NAME="coupons_import_presigned_url"
ZIP_FILE_PATH="./dist/coupons_import_presigned_url.zip"  # Adjust as needed

# 1. Update the Lambda function code
aws --endpoint-url="$ENDPOINT_URL" lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$ZIP_FILE_PATH"

echo "Updated Lambda function code for '$FUNCTION_NAME'."

