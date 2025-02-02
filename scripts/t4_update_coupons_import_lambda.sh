#!/bin/bash
# Purpose: Updates the 'coupons_import' Lambda in LocalStack.

ENDPOINT_URL="http://localhost:4566"
FUNCTION_NAME="coupons_import"

# Adjust this path to match where your coupons_import.zip is located
ZIP_FILE_PATH="/Users/sergioperez/Downloads/enterprise-cloud-developer-base/lambda_functions/coupons_import.zip"

aws --endpoint-url="$ENDPOINT_URL" lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$ZIP_FILE_PATH"

echo "coupons_import lambda updated successfully."


