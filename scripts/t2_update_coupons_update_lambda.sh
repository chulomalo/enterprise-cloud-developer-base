#!/bin/bash

# Define function name and deployment package
FUNCTION_NAME="coupons_update"
ZIP_FILE="lambda/coupons_update.zip"

# Get the role ARN
ROLE_ARN=$(awslocal iam get-role --role-name coupons_production_role --query 'Role.Arn' --output text)

# Check if the function already exists
if ! awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    echo "Creating $FUNCTION_NAME function"
    awslocal lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime nodejs14.x \
        --role $ROLE_ARN \
        --handler index.handler \
        --zip-file fileb://$ZIP_FILE
    echo "$FUNCTION_NAME created successfully."
else
    echo "Function $FUNCTION_NAME already exists. Updating code..."
    awslocal lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://$ZIP_FILE
    echo "$FUNCTION_NAME updated successfully."
fi


