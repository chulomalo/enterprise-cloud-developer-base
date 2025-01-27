const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient({
    endpoint: 'http://localhost:4566',
    region: 'us-east-1'
});

exports.handler = async (event) => {
    const id = event.pathParameters.id; // Extract ID from API Gateway path
    const body = JSON.parse(event.body); // Parse request body for new values

    try {
        await dynamoDB.update({
            TableName: 'coupons',
            Key: { id },
            UpdateExpression: 'set #discount = :discount',
            ExpressionAttributeNames: {
                '#discount': 'discount'
            },
            ExpressionAttributeValues: {
                ':discount': body.discount
            }
        }).promise();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: `Coupon ${id} updated successfully.` })
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error updating coupon', error: error.message })
        };
    }
};

