#!/bin/bash

echo "Creating SNS Topic 'coupons'..."
TOPIC_ARN=$(awslocal sns create-topic --name coupons --query 'TopicArn' --output text)
echo "Created topic with ARN: $TOPIC_ARN"

