#!/bin/bash

ENDPOINT_URL="http://localhost:4566"
FUNCTION_NAME="coupons_import"
ZIP_FILE_PATH="coupons_import.zip"

if ! awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    echo "Creating new Lambda: $FUNCTION_NAME"
    awslocal lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime nodejs14.x \
        --role arn:aws:iam::000000000000:role/lambda-execution-role \
        --handler index.handler \
        --zip-file "fileb://$ZIP_FILE_PATH"
else
    echo "Updating existing Lambda: $FUNCTION_NAME"
    awslocal lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file "fileb://$ZIP_FILE_PATH"
fi

echo "Lambda $FUNCTION_NAME is deployed/updated successfully."



