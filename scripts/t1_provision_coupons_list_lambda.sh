#!/bin/bash

FUNCTION_NAME="coupons_list"
ZIP_FILE="coupons_list.zip"
ROLE_NAME="coupons_lambda_role"
RUNTIME="nodejs14.x"    # or python3.8, etc.
HANDLER="index.handler" # depends on your code

echo "Packaging and deploying the '$FUNCTION_NAME' Lambda..."

# Step 1: Retrieve the role ARN for coupons_lambda_role
ROLE_ARN=$(awslocal iam get-role \
  --role-name $ROLE_NAME \
  --query 'Role.Arn' \
  --output text)

# Step 2: Create the ZIP package
# Here we assume your Lambda code is in a folder named 'coupons_list'
# containing index.js, package.json, node_modules, etc.
zip -r "$ZIP_FILE" "./coupons_list"

# Step 3: Check if the Lambda already exists
awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Updating existing Lambda code for '$FUNCTION_NAME'"
  awslocal lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --zip-file fileb://$ZIP_FILE
else
  echo "Creating new Lambda: $FUNCTION_NAME"
  awslocal lambda create-function \
    --function-name $FUNCTION_NAME \
    --runtime $RUNTIME \
    --role $ROLE_ARN \
    --handler $HANDLER \
    --zip-file fileb://$ZIP_FILE
fi

echo "Lambda '$FUNCTION_NAME' provisioned successfully."

