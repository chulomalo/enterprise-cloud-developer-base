exports.handler = async (event) => {
    console.log("coupons_get_token invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_get_token executed successfully" }),
    };
};
