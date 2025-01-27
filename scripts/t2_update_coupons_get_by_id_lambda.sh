#!/bin/bash

FUNCTION_NAME="coupons_get_by_id"
ZIP_FILE="lambda/coupons_get_by_id.zip"
ROLE_ARN=$(awslocal iam get-role --role-name coupons_production_role --query 'Role.Arn' --output text)

echo "Deploying $FUNCTION_NAME function"

# Check if the function exists
if ! awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
    awslocal lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime nodejs14.x \
        --role $ROLE_ARN \
        --handler index.handler \
        --zip-file fileb://$ZIP_FILE
    echo "$FUNCTION_NAME created successfully."
else
    echo "$FUNCTION_NAME already exists. Skipping creation."
fi


