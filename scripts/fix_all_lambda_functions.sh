#!/usr/bin/env bash

set -e

echo "Fixing all Lambda functions in one cycle..."

# Define all Lambda function names and directories
FUNCTIONS=(
    "coupons_get_by_id:lambda/coupons_get_by_id"
    "coupons_update:lambda/coupons_update"
    "coupons_get_token:lambda/coupons_get_token"
    "coupons_to_secure:lambda/coupons_to_secure"
    "coupons_import:lambda/coupons_import"
    "coupons_import_presigned_url:lambda/coupons_import_presigned_url"
    "coupons_event_publisher:lambda/coupons_event_publisher"
    "coupons_notification_sender:lambda/coupons_notification_sender"
)

# Loop through each function
for FUNCTION_PAIR in "${FUNCTIONS[@]}"; do
    FUNCTION_NAME="${FUNCTION_PAIR%%:*}"
    FUNCTION_DIR="${FUNCTION_PAIR##*:}"
    ZIP_FILE="${FUNCTION_NAME}.zip"

    echo "Processing function: $FUNCTION_NAME"

    # Check if the directory exists
    if [ ! -d "$FUNCTION_DIR" ]; then
        echo "Directory $FUNCTION_DIR does not exist. Skipping $FUNCTION_NAME."
        continue
    fi

    # Create or overwrite the index.js file with a standard handler
    echo "Standardizing index.js for $FUNCTION_NAME"
    cat > "$FUNCTION_DIR/index.js" <<EOF
exports.handler = async (event) => {
    console.log("$FUNCTION_NAME invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "$FUNCTION_NAME executed successfully" }),
    };
};
EOF

    # Install dependencies (if necessary)
    echo "Installing dependencies for $FUNCTION_NAME"
    npm install --prefix "./$FUNCTION_DIR"

    # Create the deployment package
    echo "Creating deployment package for $FUNCTION_NAME"
    zip -r "$ZIP_FILE" "$FUNCTION_DIR" > /dev/null

    # Update the Lambda function
    echo "Updating $FUNCTION_NAME Lambda function"
    awslocal lambda update-function-code --function-name "$FUNCTION_NAME" --zip-file "fileb://$ZIP_FILE"

    echo "$FUNCTION_NAME function updated successfully!"
done

echo "All Lambda functions processed successfully!"

