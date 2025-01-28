import json
import boto3

s3 = boto3.client('s3', endpoint_url='http://localhost:4566')

def lambda_handler(event, context):
    try:
        # Parse the incoming request body
        body = json.loads(event["body"])
        coupon_id = body.get("coupon_id", "default-id")

        # Save data to S3 bucket
        s3.put_object(
            Bucket="coupons",
            Key=f"{coupon_id}.json",
            Body=json.dumps(body)
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Coupon imported successfully"})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

