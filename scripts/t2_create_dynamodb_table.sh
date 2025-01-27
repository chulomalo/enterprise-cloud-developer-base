#!/bin/bash

TABLE_NAME="coupons"
awslocal dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=50,WriteCapacityUnits=10
[ $? == 0 ] || echo "Failed to create table $TABLE_NAME"


