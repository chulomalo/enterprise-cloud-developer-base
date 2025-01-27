exports.handler = async (event) => {
    console.log("coupons_to_secure invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_to_secure executed successfully" }),
    };
};
