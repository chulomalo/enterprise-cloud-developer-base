#!/bin/bash

FUNCTION_NAME="coupons_event_publisher"
ZIP_FILE="coupons_event_publisher.zip"
HANDLER_NAME="index.handler"           # Adjust if different in your code
RUNTIME="nodejs14.x"                   # Adjust if using Python or another runtime
ROLE_ARN="arn:aws:iam::000000000000:role/coupons_production_role"  # Example role from your environment

echo "Packaging and deploying the '$FUNCTION_NAME' Lambda..."

# 1. Install dependencies (if using Node, for example)
# npm install --prefix ../lambda/coupons_event_publisher
# (Adjust paths as needed)

# 2. Create ZIP package (make sure your code is in a folder named 'coupons_event_publisher')
zip -r "$ZIP_FILE" "../lambda/coupons_event_publisher"

# 3. Check if function exists
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

