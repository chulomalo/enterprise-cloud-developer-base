#!/bin/bash

FUNCTION_NAME="coupons_to_secure"
LAMBDA_DIR="/Users/sergioperez/Downloads/enterprise-cloud-developer-base/scripts/lambda/$FUNCTION_NAME"
ZIP_FILE="$LAMBDA_DIR.zip"

echo "Updating $FUNCTION_NAME Lambda function"

# Create deployment package
cd "$LAMBDA_DIR"
zip -r "$ZIP_FILE" . || { echo "Failed to create zip package"; exit 1; }

# Update the Lambda function
awslocal lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file fileb://"$ZIP_FILE" || { echo "Failed to update function code"; exit 1; }

echo "$FUNCTION_NAME Lambda function updated successfully"


