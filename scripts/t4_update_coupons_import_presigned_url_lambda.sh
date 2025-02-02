#!/bin/bash
# Purpose: Updates the 'coupons_import_presigned_url' Lambda in LocalStack.

ENDPOINT_URL="http://localhost:4566"
FUNCTION_NAME="coupons_import_presigned_url"

# Adjust this path to match where your coupons_import_presigned_url.zip is
ZIP_FILE_PATH="/Users/sergioperez/Downloads/enterprise-cloud-developer-base/lambda_functions/coupons_import_presigned_url.zip"

aws --endpoint-url="$ENDPOINT_URL" lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$ZIP_FILE_PATH"

echo "coupons_import_presigned_url lambda updated successfully."

