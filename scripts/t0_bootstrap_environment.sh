#!/usr/bin/env bash

API_NAME="coupons"
API_BASE_URL="http://localhost:4566"
REGION="us-east-1"
STAGE="local"

function fail() {
  echo $2
  exit 1
}

echo "Creating production policy"

POLICY_ARN="arn:aws:iam::000000000000:policy/coupons_production_policy"

# Check if the policy exists
if ! awslocal iam get-policy --policy-arn $POLICY_ARN 2>/dev/null; then
    awslocal iam create-policy \
        --policy-name "coupons_production_policy" \
        --policy-document file://scripts/coupons_production_policy.json
    [ $? == 0 ] || fail 1 "Failed to create production policy"
else
    echo "Policy already exists, skipping creation"
fi

echo "Creating production role for lambda functions"

ROLE_NAME="coupons_production_role"
ASSUME_ROLE_POLICY_FILE="scripts/coupons_lambda_role_assume_role_policy.json"

# Check if the role exists
if ! awslocal iam get-role --role-name $ROLE_NAME 2>/dev/null; then
    awslocal iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://$ASSUME_ROLE_POLICY_FILE
    [ $? == 0 ] || fail 2 "Failed to create production role"
else
    echo "Role $ROLE_NAME already exists, skipping creation"
fi

echo "Attaching policy to role"

# Check if the policy is already attached to the role
if ! awslocal iam list-attached-role-policies --role-name $ROLE_NAME | grep -q $POLICY_ARN; then
    awslocal iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn $POLICY_ARN
    [ $? == 0 ] || fail 3 "Failed to attach policy to role"
else
    echo "Policy already attached to role, skipping attachment"
fi

echo "Creating DynamoDB Table for users"

TABLE_NAME="users"

# Check if the table already exists
if ! awslocal dynamodb describe-table --table-name $TABLE_NAME 2>/dev/null; then
    awslocal dynamodb create-table \
        --table-name $TABLE_NAME \
        --attribute-definitions AttributeName=username,AttributeType=S \
        --key-schema AttributeName=username,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    [ $? == 0 ] || fail 1 "Failed to create DynamoDB Table"
else
    echo "Table $TABLE_NAME already exists, skipping creation"
fi

echo "Adding sample user to database"
awslocal dynamodb put-item \
    --table-name "users" \
    --item '{"username":{"S":"tester1"},"password":{"S":"$2a$12$wCqYSCDDoHdlUCI7rBBHO..c4KleiSzZqH8NXMHdLIcLsVxFmvG7C"}}' \
    --return-consumed-capacity TOTAL \
    --return-item-collection-metrics SIZE
[ $? == 0 ] || fail 1 "Failed to add sample user to database"
echo "Plaintext: Pc4RM0AMKy5aSGfD"

awslocal dynamodb put-item \
    --table-name "users" \
    --item '{"username":{"S":"tester2"},"password":{"S":"$2a$12$KWfAWTZM9npRke3tWZcoE.f1fD6jNTfYwYeZv4A7WTBOl1PCYxlnW"}}' \
    --return-consumed-capacity TOTAL \
    --return-item-collection-metrics SIZE
[ $? == 0 ] || fail 1 "Failed to add sample user to database"
echo "Plaintext: 4LWs6xnc1t32BzXA"

echo "Processing Lambda functions dynamically"

# Define a simple array for Lambda functions
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

# Get the role ARN
ROLE_ARN=$(awslocal iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text)

# Loop through the Lambda functions
for FUNCTION_PAIR in "${FUNCTIONS[@]}"; do
    FUNCTION_NAME="${FUNCTION_PAIR%%:*}"
    FUNCTION_DIR="${FUNCTION_PAIR##*:}"
    ZIP_FILE="${FUNCTION_DIR}.zip"

    echo "Processing function: $FUNCTION_NAME"

    # Check if the function directory exists
    if [ ! -d "$FUNCTION_DIR" ]; then
        echo "Directory $FUNCTION_DIR does not exist. Skipping $FUNCTION_NAME."
        continue
    fi

    # Install dependencies
    echo "Installing dependencies for $FUNCTION_NAME"
    npm install --prefix "./$FUNCTION_DIR"
    [ $? == 0 ] || fail 1 "Failed to install dependencies for $FUNCTION_NAME"

    # Create deployment package
    echo "Creating deployment package for $FUNCTION_NAME"
    zip -r "$ZIP_FILE" "$FUNCTION_DIR"
    [ $? == 0 ] || fail 2 "Failed to create deployment package for $FUNCTION_NAME"

    # Deploy Lambda function
    if ! awslocal lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
        echo "Creating $FUNCTION_NAME function"
        awslocal lambda create-function \
            --function-name $FUNCTION_NAME \
            --runtime nodejs14.x \
            --role $ROLE_ARN \
            --handler index.handler \
            --zip-file fileb://$ZIP_FILE
        [ $? == 0 ] || fail 3 "Failed to create function $FUNCTION_NAME"
    else
        echo "Function $FUNCTION_NAME already exists. Skipping creation."
    fi
done

echo "Creating REST API"
API_ID=$(awslocal apigateway create-rest-api --name "${API_NAME}" --query 'id' --output text --region ${REGION})
ROOT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/`].id' --output text --region ${REGION})
awslocal apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${ROOT_RESOURCE_ID} \
    --path-part "coupons"

COUPONS_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/coupons`].id' --output text)
awslocal apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${COUPONS_RESOURCE_ID} \
    --path-part "{id}"
COUPONS_GET_BY_ID_LAMBDA_ARN=$(awslocal lambda list-functions --query "Functions[?FunctionName=='coupons_get_by_id'].FunctionArn" --output text)
awslocal apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${COUPONS_RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${COUPONS_GET_BY_ID_LAMBDA_ARN}/invocations
awslocal apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE}

# Add the REST API and related resources (unchanged from your script)

echo "All tasks completed successfully"
