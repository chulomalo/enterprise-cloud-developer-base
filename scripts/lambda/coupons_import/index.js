// index.js
const AWS = require('aws-sdk');

// Configure the S3 client to point to LocalStack
const s3 = new AWS.S3({
  endpoint: process.env.S3_ENDPOINT || 'http://localhost:4566',
  s3ForcePathStyle: true, // Required for LocalStack
  region: process.env.AWS_REGION || 'us-east-1'
});

exports.handler = async (event) => {
  try {
    // 1. Parse the incoming event from API Gateway
    //    Assuming event.body is a JSON string with { "coupon_id": "...", "coupon_data": ... }
    const body = JSON.parse(event.body);
    const { coupon_id, coupon_data } = body;

    // 2. Construct the JSON object to save
    const fileContent = {
      coupon_id,
      coupon_data,
      imported_at: new Date().toISOString()
    };

    // 3. Prepare S3 upload parameters
    const bucketName = 'coupons';  // or your local S3 bucket name
    const fileName = `${coupon_id}.json`;

    const params = {
      Bucket: bucketName,
      Key: fileName,
      Body: JSON.stringify(fileContent),
      ContentType: 'application/json'
    };

    // 4. Upload the JSON to S3
    await s3.putObject(params).promise();

    // 5. Return a success response
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Coupon import successful',
        fileSaved: fileName
      })
    };
  } catch (error) {
    console.error('Error in coupons_import:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to import coupon' })
    };
  }
};

