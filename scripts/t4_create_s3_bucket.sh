#!/bin/bash

# Purpose: Creates an S3 bucket named "coupons" in LocalStack with a private ACL.

# Set LocalStack endpoint
ENDPOINT_URL="http://localhost:4566"

# 1. Create the S3 bucket with private ACL
aws --endpoint-url="$ENDPOINT_URL" s3api create-bucket \
    --bucket coupons \
    --acl private

echo "Bucket 'coupons' created with private ACL in LocalStack."

