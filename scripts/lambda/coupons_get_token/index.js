const AWS = require('aws-sdk');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = "0HXc4w5NEzA61HkV";
const TABLE_NAME = "users";

exports.handler = async (event) => {
    const body = JSON.parse(event.body);

    const { username, password } = body;
    if (!username || !password) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Username and password are required" })
        };
    }

    try {
        // Fetch user from DynamoDB
        const params = {
            TableName: TABLE_NAME,
            Key: { username }
        };
        const result = await dynamodb.get(params).promise();

        if (!result.Item) {
            return {
                statusCode: 403,
                body: JSON.stringify({ message: "Invalid username or password" })
            };
        }

        // Compare password with hashed password
        const validPassword = await bcrypt.compare(password, result.Item.password);
        if (!validPassword) {
            return {
                statusCode: 403,
                body: JSON.stringify({ message: "Invalid username or password" })
            };
        }

        // Generate JWT token
        const token = jwt.sign({ username }, JWT_SECRET, { expiresIn: "1h" });
        return {
            statusCode: 200,
            body: JSON.stringify({ token, expiresIn: 3600 })
        };

    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Internal server error" })
        };
    }
};

