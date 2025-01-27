const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient({
    endpoint: 'http://localhost:4566',
    region: 'us-east-1'
});

exports.handler = async (event) => {
    const id = event.pathParameters.id; // Retrieve the ID from the API Gateway event

    try {
        const result = await dynamoDB.get({
            TableName: 'coupons',
            Key: { id }
        }).promise();

        if (!result.Item) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: 'Coupon not found' })
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(result.Item)
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error retrieving coupon', error })
        };
    }
};

