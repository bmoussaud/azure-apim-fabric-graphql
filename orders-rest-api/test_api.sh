#!/bin/bash
# Test script for Orders REST API

set -ex
source .env

# Check if /apim flag exists in command line arguments
APIM_MODE=false
for arg in "$@"; do
  if [ "$arg" = "/apim" ]; then
    APIM_MODE=true
    break
  fi
done

if [ "$APIM_MODE" = true ]; then
  echo "Running in APIM mode"
  API_BASE_URL="${ORDERS_API_URL:-http://localhost:8000}"
  AUTH_HEADER="Ocp-Apim-Subscription-Key: ${ORDERS_APIM_SUBSCRIPTION_KEY:-test-subscription-key}"
else
  echo "Running in direct mode"
  API_BASE_URL="${ORDERS_CONTAINER_APP_URL:-http://localhost:8000}"
  AUTH_HEADER="X-Auth-Token: test-token"
fi

echo "${API_BASE_URL}"
echo ${AUTH_HEADER}

echo "Testing Orders REST API at ${API_BASE_URL}"
echo "=========================================="

# Test health endpoint
echo ""
echo "1. Testing health check..."
curl -s "${API_BASE_URL}/health" | jq

# Test root endpoint
echo ""
echo "2. Testing root endpoint..."
curl -s "${API_BASE_URL}/" | jq

# Test list all orders WITHOUT auth header (should fail with 403)
echo ""
echo "3a. Testing list all orders WITHOUT auth header (should return 403)..."
curl -s "${API_BASE_URL}/orders" -w "\nHTTP Status: %{http_code}\n" | jq || true

# Test list all orders WITH auth header
echo ""
echo "3b. Testing list all orders WITH auth header..."
curl -s -H "${AUTH_HEADER}" "${API_BASE_URL}/orders" | jq 

# Test list orders with status filter
echo ""
echo "4. Testing list orders with status filter (pending)..."
curl -s -H "${AUTH_HEADER}" "${API_BASE_URL}/orders?status_filter=pending&limit=3" | jq

# Test get specific order
echo ""
echo "5. Testing get specific order (ORD-2024-001)..."
curl -s -H "${AUTH_HEADER}" "${API_BASE_URL}/orders/ORD-2024-001" | jq

# Test create order
echo ""
echo "6. Testing create new order..."
NEW_ORDER=$(curl -s -X POST "${API_BASE_URL}/orders" \
  -H "Content-Type: application/json" \
  -H "${AUTH_HEADER}" \
  -d '{
    "customer_id": "CUST-999",
    "customer_name": "Test Customer",
    "customer_email": "test@example.com",
    "items": [
      {
        "product_id": "PROD-001",
        "product_name": "Test Product",
        "quantity": 2,
        "unit_price": 50.00,
        "total_price": 100.00
      }
    ],
    "shipping_address": "123 Test St, Test City, TS 12345",
    "notes": "Test order from API test script"
  }')

echo "$NEW_ORDER" | jq
ORDER_ID=$(echo "$NEW_ORDER" | python -c "import sys, json; print(json.load(sys.stdin)['order_id'])")
echo "Created order ID: $ORDER_ID"

# Test update order
echo ""
echo "7. Testing update order status..."
curl -s -X PUT "${API_BASE_URL}/orders/${ORDER_ID}" \
  -H "Content-Type: application/json" \
  -H "${AUTH_HEADER}" \
  -d '{"status": "processing", "notes": "Updated from test script"}' | jq

# Test get updated order
echo ""
echo "8. Verifying order was updated..."
curl -s -H "${AUTH_HEADER}" "${API_BASE_URL}/orders/${ORDER_ID}" | jq



echo ""
echo "=========================================="
echo "All tests completed!"
