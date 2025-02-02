import json
import boto3
import os

def lambda_handler(event, context):
    """
    Receives a coupon import request, extracts 'coupon_id' and other data,
    and saves the coupon as <coupon_id>.json in the 'coupons' bucket.
    """

    # 1. Create an S3 client that points to LocalStack
    s3_client = boto3.client(
        "s3",
        endpoint_url=os.environ.get("LOCALSTACK_ENDPOINT", "http://localhost:4566")
    )

    bucket_name = "coupons"

    # 2. Parse the incoming event (body field)
    body = event.get("body")
    if not body:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing request body"})
        }

    # Convert body from JSON string to a dictionary
    data = json.loads(body)

    # 3. Extract coupon_id
    coupon_id = data.get("coupon_id")
    if not coupon_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing coupon_id"})
        }

    # 4. Construct the filename <coupon_id>.json
    filename = f"{coupon_id}.json"

    # 5. Convert data to JSON and upload to S3
    try:
        json_content = json.dumps(data)  # Re-serialize
        s3_client.put_object(
            Bucket=bucket_name,
            Key=filename,
            Body=json_content,
            ContentType="application/json"
        )
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Coupon imported successfully",
                "filename": filename
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

