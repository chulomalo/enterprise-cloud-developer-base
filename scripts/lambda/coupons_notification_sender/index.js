// index.js
const AWS = require('aws-sdk');

// Create an SNS client pointing to LocalStack
const sns = new AWS.SNS({
  endpoint: process.env.SNS_ENDPOINT || 'http://localhost:4566',
  region: process.env.AWS_REGION || 'us-east-1'
});

exports.handler = async (event) => {
  try {
    // 1. Parse the incoming event (assuming event.body is JSON)
    const body = JSON.parse(event.body);
    const { email, subject, message_text } = body;

    // 2. Build the SNS publish parameters
    //    The 'coupons' topic ARN is typically "arn:aws:sns:us-east-1:000000000000:coupons" in LocalStack
    const params = {
      TopicArn: 'arn:aws:sns:us-east-1:000000000000:coupons',
      Message: message_text,
      Subject: subject,
      MessageAttributes: {
        RecipientEmail: {
          DataType: 'String',
          StringValue: email
        }
      }
    };

    // 3. Publish the message to SNS
    await sns.publish(params).promise();

    // 4. Return a successful response
    return {
      statusCode: 200,
      body: JSON.stringify({ status: 'Notification sent to SNS', params })
    };
  } catch (err) {
    console.error('Error in coupons_notification_sender Lambda:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to send notification' })
    };
  }
};

