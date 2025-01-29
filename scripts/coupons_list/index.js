exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event));
  return {
    statusCode: 200,
    body: JSON.stringify({ "coupons": [{ "id": 123, "description": "Sample" }] })
  };
};

