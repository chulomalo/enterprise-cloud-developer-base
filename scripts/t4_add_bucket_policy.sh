#!/bin/bash

# Purpose: Adds a bucket policy to enforce MFA delete on the "coupons" S3 bucket.

ENDPOINT_URL="http://localhost:4566"
BUCKET_NAME="coupons"

# 1. Enable versioning with MFA delete
aws --endpoint-url="$ENDPOINT_URL" s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled,MFADelete=Enabled \
    --mfa "arn:aws:iam::000000000000:mfa/root-account-mfa-device 123456"

echo "Bucket versioning with MFA Delete enabled."

# 2. Put the bucket policy
POLICY_DOCUMENT='{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"RequireMFADelete",
      "Effect":"Deny",
      "Principal":"*",
      "Action":"s3:DeleteObject",
      "Resource":"arn:aws:s3:::coupons/*",
      "Condition":{
        "Bool":{
          "aws:MultiFactorAuthPresent":"false"
        }
      }
    }
  ]
}'

aws --endpoint-url="$ENDPOINT_URL" s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy "$POLICY_DOCUMENT"

echo "Bucket policy requiring MFA for deletions has been added."

