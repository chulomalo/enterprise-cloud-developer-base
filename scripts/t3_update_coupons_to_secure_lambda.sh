#!/bin/bash

# Function name
FUNCTION_NAME="coupons_to_secure"

# Paths
BASE_DIR="/Users/sergioperez/Downloads/enterprise-cloud-developer-base/scripts"
LAMBDA_DIR="$BASE_DIR/lambda/$FUNCTION_NAME"
ZIP_FILE="$BASE_DIR/$FUNCTION_NAME.zip"

# Step 1: Navigate to Lambda directory
if [ -d "$LAMBDA_DIR" ]; then
    echo "Navigating to Lambda directory: $LAMBDA_DIR"
    cd "$LAMBDA_DIR" || { echo "Failed to change directory to $LAMBDA_DIR"; exit 1; }
else
    echo "Lambda directory $LAMBDA_DIR does not exist!"
    exit 1
fi

# Step 2: Install dependencies
echo "Installing dependencies..."
npm install || { echo "Failed to install dependencies"; exit 1; }

# Step 3: Create a deployment package (ZIP file)
echo "Creating deployment package..."
cd "$BASE_DIR" || { echo "Failed to change directory to $BASE_DIR"; exit 1; }
zip -r "$ZIP_FILE" "lambda/$FUNCTION_NAME" || { echo "Failed to create ZIP file"; exit 1; }

# Step 4: Update the Lambda function
echo "Updating the Lambda function: $FUNCTION_NAME"
awslocal lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$ZIP_FILE" || { echo "Failed to update Lambda function"; exit 1; }

echo "Lambda function $FUNCTION_NAME updated successfully!"

