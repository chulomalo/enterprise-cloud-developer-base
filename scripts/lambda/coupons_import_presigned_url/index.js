exports.handler = async (event) => {
    console.log("coupons_import_presigned_url invoked with event:", event);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "coupons_import_presigned_url executed successfully" }),
    };
};

