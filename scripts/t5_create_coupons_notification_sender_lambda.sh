#!/bin/bash

FUNCTION_NAME="coupons_notification_sender"
ZIP_FILE="coupons_notification_sender.zip"

if ! awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    echo "Creating Lambda function: $FUNCTION_NAME"
    awslocal lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime nodejs14.x \
        --role arn:aws:iam::000000000000:role/lambda-execution-role \
        --handler index.handler \
        --zip-file "fileb://${ZIP_FILE}"
else
    echo "Updating existing Lambda code: $FUNCTION_NAME"
    awslocal lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file "fileb://${ZIP_FILE}"
fi

echo "Lambda function '${FUNCTION_NAME}' deployment script finished."
