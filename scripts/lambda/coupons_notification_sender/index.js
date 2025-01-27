exports.handler = async (event) => {
    console.log("coupons_notification_sender invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_notification_sender executed successfully" }),
    };
};

