#!/bin/bash

# Step 1: Create the API Gateway
API_ID=$(aws --endpoint-url=$ENDPOINT_URL apigateway create-rest-api \
  --name "coupons" \
  --query 'id' --output text)

echo "API Gateway created with ID: $API_ID"

# Step 2: Get the Root Resource ID
ROOT_ID=$(aws --endpoint-url=$ENDPOINT_URL apigateway get-resources \
  --rest-api-id $API_ID \
  --query 'items[0].id' --output text)

echo "Root Resource ID: $ROOT_ID"

# Step 3: Create a new resource for /coupons_poc
RESOURCE_ID=$(aws --endpoint-url=$ENDPOINT_URL apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part "coupons_poc" \
  --query 'id' --output text)

echo "Resource /coupons_poc created with ID: $RESOURCE_ID"

# Step 4: Add GET method to the /coupons_poc resource
aws --endpoint-url=$ENDPOINT_URL apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type "NONE"

echo "GET method added to /coupons_poc"

# Step 5: Integrate the GET method with the Lambda function
aws --endpoint-url=$ENDPOINT_URL apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:coupons_list/invocations

echo "GET method integrated with Lambda function coupons_list"

# Step 6: Deploy the API
aws --endpoint-url=$ENDPOINT_URL apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name test

echo "API deployed to stage: test"
echo "API Gateway endpoint created successfully: http://localhost:4566/restapis/$API_ID/test/_user_request_/coupons_poc"

