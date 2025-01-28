#!/bin/bash

FUNCTION_NAME="coupons_get_token"

zip -r coupons_get_token.zip lambda/coupons_get_token
awslocal lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --zip-file fileb://coupons_get_token.zip

