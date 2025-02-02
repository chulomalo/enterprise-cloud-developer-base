const AWS = require('aws-sdk');

const s3 = new AWS.S3({
    endpoint: 'http://localhost:4566', // Explicitly set LocalStack S3 endpoint
    s3ForcePathStyle: true,           // Use path-style URLs (required for LocalStack)
    region: 'us-east-1'               // Ensure region is set correctly
});

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    try {
        // Parse the incoming request body
        const body = JSON.parse(event.body);
        const couponId = body.coupon_id;
        const fileName = `${couponId}.json`;

        console.log(`Parsed coupon_id: ${couponId}`);

        // Upload the JSON file to the S3 bucket
        const params = {
            Bucket: 'coupons',
            Key: fileName,
            Body: JSON.stringify(body),
        };

        await s3.putObject(params).promise();

        console.log(`Successfully uploaded ${fileName} to the S3 bucket`);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Coupon imported successfully' }),
        };
    } catch (error) {
        console.error('Error:', error);

        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    }
};

