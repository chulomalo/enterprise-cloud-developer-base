#!/bin/bash

# Step 1: Create API Gateway
API_ID=$(awslocal apigateway create-rest-api --name "CouponsAPI" | jq -r '.id')

# Step 2: Get root resource ID
ROOT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID | jq -r '.items[0].id')

# Step 3: Create '/coupons' resource
RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_RESOURCE_ID \
  --path-part coupons | jq -r '.id')

# Step 4: Add POST method to '/coupons'
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method POST \
  --authorization-type NONE

# Step 5: Integrate POST method with Lambda
awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:local:lambda:path/2015-03-31/functions/arn:aws:lambda:local:123456789012:function:coupons_import/invocations

# Step 6: Deploy the API
awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name test

echo "API Gateway setup complete. Test endpoint: http://localhost:4566/restapis/$API_ID/test/_user_request_/coupons"


