#!/bin/bash

awslocal dynamodb update-table \
    --table-name coupons \
    --attribute-definitions \
        AttributeName=provider_id,AttributeType=S \
        AttributeName=campaign_id,AttributeType=S \
    --global-secondary-index-updates \
        "[{\"Create\":{\"IndexName\": 
\"ProviderCampaignIndex\",\"KeySchema\":[{\"AttributeName\":\"provider_id\",\"KeyType\":\"HASH\"},{\"AttributeName\":\"campaign_id\",\"KeyType\":\"RANGE\"}],\"Projection\":{\"ProjectionType\":\"ALL\"},\"ProvisionedThroughput\":{\"ReadCapacityUnits\":50,\"WriteCapacityUnits\":10}}}]"

