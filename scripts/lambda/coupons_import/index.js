exports.handler = async (event) => {
    console.log("coupons_import invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_import executed successfully" }),
    };
};
