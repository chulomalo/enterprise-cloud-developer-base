// index.js
const AWS = require('aws-sdk');

// Configure the S3 client to point to LocalStack
const s3 = new AWS.S3({
  endpoint: process.env.S3_ENDPOINT || 'http://localhost:4566',
  s3ForcePathStyle: true,
  region: process.env.AWS_REGION || 'us-east-1'
});

exports.handler = async (event) => {
  try {
    // 1. Parse the incoming request
    //    Example: event.body might be {"filename":"abc.json"}
    const body = JSON.parse(event.body);
    const { filename } = body;

    if (!filename) {
      throw new Error('Filename not specified');
    }

    // 2. Generate a pre-signed URL restricted to the specified filename
    const bucketName = 'coupons';  // same S3 bucket as before
    const params = {
      Bucket: bucketName,
      Key: filename,
      Expires: 60, // URL valid for 60 seconds
      ContentType: 'application/json' // Or whichever type you expect
    };

    // getSignedUrl for PUT operation
    const presignedUrl = await s3.getSignedUrlPromise('putObject', params);

    // 3. Return the URL in a response
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Presigned URL generated successfully',
        url: presignedUrl
      })
    };
  } catch (error) {
    console.error('Error in coupons_import_presigned_url:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};

