# Orders REST API

A REST API for managing orders with full CRUD (Create, Read, Update, Delete) operations.

## Features

- **List Orders**: Get all orders with optional filtering by status
- **Get Order**: Retrieve a specific order by ID
- **Create Order**: Create a new order
- **Update Order**: Update order status, shipping address, or notes
- **Delete Order**: Remove an order from the system
- Fake data generator for testing (20 sample orders)
- FastAPI with automatic OpenAPI documentation
- Pydantic models for data validation

## Installation

Using `uv` (recommended):

```bash
cd orders-rest-api
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv sync
```

## Running the API

```bash
uv run main.py
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- Interactive API documentation (Swagger UI): `http://localhost:8000/docs`
- Alternative API documentation (ReDoc): `http://localhost:8000/redoc`
- OpenAPI schema: `http://localhost:8000/openapi.json`

## API Endpoints

### List All Orders
```bash
GET /orders
```

Optional query parameters:
- `status_filter`: Filter by status (pending, processing, shipped, delivered, cancelled)
- `limit`: Limit the number of results

Example:
```bash
curl http://localhost:8000/orders?status_filter=pending&limit=5
```

### Get Order by ID
```bash
GET /orders/{order_id}
```

Example:
```bash
curl http://localhost:8000/orders/ORD-2024-001
```

### Create New Order
```bash
POST /orders
Content-Type: application/json

{
  "customer_id": "CUST-12345",
  "customer_name": "John Doe",
  "customer_email": "john.doe@example.com",
  "items": [
    {
      "product_id": "PROD-001",
      "product_name": "Laptop",
      "quantity": 1,
      "unit_price": 999.99,
      "total_price": 999.99
    }
  ],
  "shipping_address": "123 Main St, City, State 12345",
  "notes": "Please handle with care"
}
```

### Update Order
```bash
PUT /orders/{order_id}
Content-Type: application/json

{
  "status": "processing",
  "notes": "Updated notes"
}
```

### Delete Order
```bash
DELETE /orders/{order_id}
```

## Order Status Values

- `pending`: Order has been placed but not yet processed
- `processing`: Order is being prepared
- `shipped`: Order has been shipped
- `delivered`: Order has been delivered
- `cancelled`: Order has been cancelled

## Testing with curl


```bash
azd env get-values > .env
./test_api [/apim]
```

```bash
# List all orders
curl http://localhost:8000/orders

# Get a specific order
curl http://localhost:8000/orders/ORD-2024-001

# Create a new order
curl -X POST http://localhost:8000/orders \
  -H "Content-Type: application/json" \
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
    "shipping_address": "123 Test St",
    "notes": "Test order"
  }'

# Update order status
curl -X PUT http://localhost:8000/orders/ORD-2024-001 \
  -H "Content-Type: application/json" \
  -d '{"status": "processing"}'

# Delete an order
curl -X DELETE http://localhost:8000/orders/ORD-2024-001
```

## Deployment with Azure API Management

This API is designed to be deployed behind Azure API Management (APIM). See the infrastructure configuration in the `infra` directory for deployment details.

## Data Model

### Order
- `order_id`: Unique order identifier
- `customer_id`: Customer identifier
- `customer_name`: Customer name
- `customer_email`: Customer email
- `order_date`: Order creation timestamp
- `status`: Current order status
- `items`: List of ordered items
- `subtotal`: Subtotal amount
- `tax`: Tax amount (8%)
- `shipping_cost`: Shipping cost ($15 or free over $100)
- `total_amount`: Total order amount
- `shipping_address`: Shipping address
- `notes`: Optional order notes

### OrderItem
- `product_id`: Product identifier
- `product_name`: Product name
- `quantity`: Quantity ordered
- `unit_price`: Price per unit
- `total_price`: Total price for this item
