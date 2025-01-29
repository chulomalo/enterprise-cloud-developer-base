#!/bin/bash

FUNCTION_NAME="coupons_notification_sender"
ZIP_FILE="coupons_notification_sender.zip"
HANDLER_NAME="index.handler"  
RUNTIME="nodejs14.x"
ROLE_ARN="arn:aws:iam::000000000000:role/coupons_production_role"

echo "Packaging and deploying the '$FUNCTION_NAME' Lambda..."

# 1. (Optional) Install dependencies if needed
# npm install --prefix ../lambda/coupons_notification_sender

# 2. Create deployment package
zip -r "$ZIP_FILE" "../lambda/coupons_notification_sender"

# 3. Check if Lambda exists
awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Updating existing Lambda: $FUNCTION_NAME"
    awslocal lambda update-function-code \
      --function-name $FUNCTION_NAME \
      --zip-file fileb://$ZIP_FILE
else
    echo "Creating new Lambda: $FUNCTION_NAME"
    awslocal lambda create-function \
      --function-name $FUNCTION_NAME \
      --runtime $RUNTIME \
      --role $ROLE_ARN \
      --handler $HANDLER_NAME \
      --zip-file fileb://$ZIP_FILE
fi

echo "Lambda '$FUNCTION_NAME' deployed successfully."

