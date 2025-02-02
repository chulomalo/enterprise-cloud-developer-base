// index.js
const AWS = require('aws-sdk');

// Create a Kinesis client pointing to LocalStack
const kinesis = new AWS.Kinesis({
  endpoint: process.env.KINESIS_ENDPOINT || 'http://localhost:4566',
  region: process.env.AWS_REGION || 'us-east-1'
});

exports.handler = async (event) => {
  try {
    // 1. Parse the incoming event to extract relevant data
    //    Example: We assume 'event.body' is a JSON string from API Gateway
    const body = JSON.parse(event.body);
    const { coupon_id, coupon_data } = body;

    // 2. Construct the Kinesis message payload (similar to t5_sample_stream_message.json)
    const message = {
      coupon_id,
      coupon_data,
      timestamp: new Date().toISOString()
    };

    // 3. Publish the record to the Kinesis stream named 'coupons'
    const params = {
      StreamName: 'coupons',
      PartitionKey: coupon_id,  // a unique identifier or just coupon_id
      Data: JSON.stringify(message)
    };

    await kinesis.putRecord(params).promise();

    // 4. Return a successful response
    return {
      statusCode: 200,
      body: JSON.stringify({
        status: 'Message published to Kinesis',
        message
      })
    };
  } catch (err) {
    console.error('Error in coupons_event_publisher Lambda:', err);

    // Return an error response
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to publish to Kinesis' })
    };
  }
};

