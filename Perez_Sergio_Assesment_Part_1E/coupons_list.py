import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "coupons": [
                {"id": "1", "discount": "10%"},
                {"id": "2", "discount": "20%"}
            ]
        })
    }

