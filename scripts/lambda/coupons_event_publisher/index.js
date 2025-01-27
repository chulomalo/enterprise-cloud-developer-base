exports.handler = async (event) => {
    console.log("coupons_event_publisher invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_event_publisher executed successfully" }),
    };
};

