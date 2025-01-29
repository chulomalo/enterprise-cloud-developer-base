#!/bin/bash

TOPIC_ARN="arn:aws:sns:us-east-1:000000000000:coupons"

echo "Attaching policy to restrict 'coupons' topic to email protocols only..."

# Example policy JSON stored in `coupons_sns_policy.json`
# that denies subscribe requests for non-email endpoints:
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "AllowOnlyEmailSubscription",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "SNS:Subscribe",
#       "Resource": "arn:aws:sns:us-east-1:000000000000:coupons",
#       "Condition": {
#         "StringEquals": {
#           "sns:Protocol": "email"
#         }
#       }
#     }
#   ]
# }

awslocal sns set-topic-attributes \
    --topic-arn "$TOPIC_ARN" \
    --attribute-name "Policy" \
    --attribute-value file://coupons_sns_policy.json

echo "Policy attached to SNS Topic: $TOPIC_ARN"

