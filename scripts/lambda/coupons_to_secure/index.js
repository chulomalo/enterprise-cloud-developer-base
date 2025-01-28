const jwt = require('jsonwebtoken');
const SECRET = "0HXc4w5NEzA61HkV";

exports.handler = async (event) => {
    const token = event.headers.Authorization;

    if (!token) {
        return {
            statusCode: 403,
            body: JSON.stringify({ message: "Token is required" }),
        };
    }

    try {
        jwt.verify(token, SECRET);
        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Access granted" }),
        };
    } catch (err) {
        return {
            statusCode: 403,
            body: JSON.stringify({ message: "Invalid token" }),
        };
    }
};

