#!/bin/bash
echo "Creating Kinesis data stream named 'coupons' with 5 shards."

# Use 'awslocal' if available, else 'aws --endpoint-url=http://localhost:4566'
awslocal kinesis create-stream \
    --stream-name coupons \
    --shard-count 5

echo "Kinesis data stream 'coupons' created successfully."

