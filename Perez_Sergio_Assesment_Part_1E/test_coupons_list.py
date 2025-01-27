import unittest
import json
from coupons_list import lambda_handler

class TestCouponsList(unittest.TestCase):
    def test_lambda_handler(self):
        # Simulate an event that mimics API Gateway input
        event = {}
        context = {}

        # Call the Lambda function
        response = lambda_handler(event, context)

        # Assert the response status code is 200
        self.assertEqual(response['statusCode'], 200)

        # Parse the body and assert its structure
        body = json.loads(response['body'])
        self.assertIn('coupons', body)
        self.assertIsInstance(body['coupons'], list)

        # Assert specific coupon values
        self.assertEqual(body['coupons'][0]['id'], "1")
        self.assertEqual(body['coupons'][0]['discount'], "10%")
        self.assertEqual(body['coupons'][1]['id'], "2")
        self.assertEqual(body['coupons'][1]['discount'], "20%")

if __name__ == '__main__':
    unittest.main()

