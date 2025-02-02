import json
import boto3
import os

def lambda_handler(event, context):
    """
    Generates a presigned URL for uploading a specific file to the 'coupons' bucket.
    """

    # 1. Create an S3 client pointing to LocalStack
    s3_client = boto3.client(
        "s3",
        endpoint_url=os.environ.get("LOCALSTACK_ENDPOINT", "http://localhost:4566")
    )

    bucket_name = "coupons"

    # 2. Parse the event body
    body = event.get("body")
    if not body:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing request body"})
        }
    data = json.loads(body)

    filename = data.get("filename")
    if not filename:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing filename"})
        }

    # 3. Generate a presigned URL that only allows PUT of 'filename'
    try:
        presigned_url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={
                "Bucket": bucket_name,
                "Key": filename
            },
            ExpiresIn=3600  # valid for 1 hour
        )
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Presigned URL generated successfully",
                "filename": filename,
                "presigned_url": presigned_url
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

