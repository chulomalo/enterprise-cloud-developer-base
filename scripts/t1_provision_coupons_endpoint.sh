#!/bin/bash

# --- VARIABLES ---
API_NAME="coupons"             # The name of the existing or desired API
STAGE_NAME="local"             # The deployment stage name
ENDPOINT_PATH="coupons_poc"    # The path-part for the new endpoint (/coupons_poc)
LAMBDA_NAME="coupons_list"     # The Lambda function that will handle GET requests

echo "==========================================="
echo " START: Creating or Updating /$ENDPOINT_PATH Endpoint"
echo "==========================================="

# 1. Check if the API named 'coupons' exists
# -----------------------------------------------------
#   'awslocal apigateway get-rest-apis' returns a list of all APIs.
#   We filter by name=='coupons' to see if it’s already created.
API_ID=$(awslocal apigateway get-rest-apis \
            --query "items[?name=='$API_NAME'].id" \
            --output text 2>/dev/null)

if [ -z "$API_ID" ]; then
    echo "API '$API_NAME' does not exist. Creating a new one..."

    # 2. Create the API if it doesn't exist
    # ---------------------------------------------------------
    #   'create-rest-api' will create an API in LocalStack named 'coupons'.
    API_ID=$(awslocal apigateway create-rest-api \
               --name "$API_NAME" \
               --query 'id' \
               --output text)
    echo "Created API with ID: $API_ID"

else
    echo "Found existing API '$API_NAME' with ID: $API_ID"
fi

# 3. Retrieve the root resource ID (the '/' path) for this API
# ------------------------------------------------------------
#   Every API has a root resource (path=="/"). We need its ID to attach child resources.
ROOT_RESOURCE_ID=$(awslocal apigateway get-resources \
  --rest-api-id $API_ID \
  --query 'items[?path==`/`].id' \
  --output text)

echo "Root resource ID for API '$API_NAME' is: $ROOT_RESOURCE_ID"

# 4. Create the /coupons_poc resource under the root
# ---------------------------------------------------
#   'create-resource' adds a new path-part to the existing API tree.
#   The parent ID is the root resource ID, so the path will become '/coupons_poc'.
RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_RESOURCE_ID \
  --path-part $ENDPOINT_PATH \
  --query 'id' \
  --output text)

echo "Created resource for '/$ENDPOINT_PATH' with ID: $RESOURCE_ID"

# 5. Define a GET method on /coupons_poc
# ---------------------------------------------------
#   'put-method' tells API Gateway to accept GET requests on that resource.
#   '--authorization-type NONE' means no auth is required (e.g., no API keys).
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type "NONE"

echo "Defined GET method on /$ENDPOINT_PATH"

# 6. Integrate GET /coupons_poc with the coupons_list Lambda (AWS_PROXY)
# ---------------------------------------------------
#   First, get the Lambda ARN from LocalStack. We'll connect the GET method to it.
LAMBDA_ARN=$(awslocal lambda list-functions \
  --query "Functions[?FunctionName=='$LAMBDA_NAME'].FunctionArn" \
  --output text)

echo "Lambda ARN for '$LAMBDA_NAME' is: $LAMBDA_ARN"

#   'put-integration' defines how API Gateway forwards requests to Lambda.
#   '--type AWS_PROXY' means we use a Lambda proxy integration (passes event as-is).
#   '--integration-http-method POST' is how API Gateway calls Lambda behind the scenes.
awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations"

echo "Integrated GET /$ENDPOINT_PATH with Lambda '$LAMBDA_NAME'"

# 7. Deploy or Redeploy the API to make the changes live
# ---------------------------------------------------
#   'create-deployment' publishes the API changes to the stage (e.g. 'local').
awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name $STAGE_NAME

echo "Deployed '$API_NAME' API to stage '$STAGE_NAME'."

echo "==========================================="
echo " COMPLETE: /$ENDPOINT_PATH endpoint is live "
echo "==========================================="
