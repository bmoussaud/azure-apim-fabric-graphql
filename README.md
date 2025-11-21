# Azure API Management - Fabric GraphQL Integration

This repository demonstrates how to integrate Fabric GraphQL API with Azure API Management (APIM).

![Azure API Management with GitHub GraphQL](./logo-apim-github.png)


## Setup

### Configure Fabric
1. Create a new Lakehouse, Load the data (`fabriq-graphql/factory_iot_data.csv`) and transform them into a table
2. Create a new `API For GraphQL` item, bind it to the table.
3. Copy the endpoint and set value in infra/main.parameters.json
```json
   "fabricGraphQLEndpoint": {
      "value": "https://cb0442cc43ea4c819fea0bba9b62f870.zcb.graphql.fabric.microsoft.com/v1/workspaces/cb0442cc-43ea-4c81-9fea-0bba9b62f870/graphqlapis/64f58335-5d12-441d-b5e5-51778048a084/graphql"
    }
```

### Configure The sample

1. Trigger `azd up` to update the Azure APIM Configuration
2. Get the name of the created managed identity `apim-mi-xxxxxxxx` 
3. At the workspace level,using the `Manage Acess` menu; assign the managed identity `apim-mi-xxxx ` as a contributor of the workspace.

### Test

```bash
cd fabric-graphql
azd env get-values > .env
./test-api.sh


uv venv
source .venv/bin/activate
uv run fabric_graphql_apim.py 
```

The output should look like
``` 
Using FABRIC_GRAPHQL_API_URL: https://apim-tgebslojbs6y2.azure-api.net/fabric-graphql

query {
  factory_iot_datas(first: 10) {
     items {
        Timestamp
        BuildingID
        DeviceID

     }
  }
}

Making request to: https://apim-tgebslojbs6y2.azure-api.net/fabric-graphql
Headers: {'Content-Type': 'application/json', 'Ocp-Apim-Subscription-Key': '4a33de485f7c432f9192a9a19cd1a79b'}
Response status code: 200
Response headers: {'Content-Type': 'text/plain; charset=utf-8', 'Date': 'Mon, 17 Nov 2025 08:25:46 GMT', 'Access-Control-Expose-Headers': 'x-ms-latency,RequestId', 'Transfer-Encoding': 'chunked', 'Strict-Transport-Security': 'max-age=31536000; includeSubDomains', 'x-ms-latency': 'overhead=1729;queryEngine=10080', 'x-ms-routing-hint': 'host001_graphql-006', 'x-ms-workload-resource-moniker': '64f58335-5d12-441d-b5e5-51778048a084', 'x-ms-root-activity-id': '31f510dd-fe75-45c1-a077-855e4dca8f2d', 'x-ms-current-utc-date': '11/17/2025 8:25:35 AM', 'X-Frame-Options': 'deny', 'X-Content-Type-Options': 'nosniff', 'request-redirected': 'true', 'home-cluster-uri': 'https://wabi-west-us3-a-primary-redirect.analysis.windows.net/', 'RequestId': '31988eb5-4cbe-44c0-9e2f-e75a3678b9e9', 'Request-Context': 'appId=cid-v1:4e244c7e-6d87-44a6-9022-c1aa461fa0c9'}
{
    "data": {
        "factory_iot_datas": {
            "items": [
                {
                    "Timestamp": "2025-11-11T17:36:24.407Z",
                    "BuildingID": "BLD-MAR-003",
                    "DeviceID": "EM-05B-G1"
                },...
```            
 
Documentation:
* https://learn.microsoft.com/en-us/fabric/data-engineering/get-started-api-graphql
* https://learn.microsoft.com/en-us/fabric/data-engineering/api-graphql-azure-api-management


### Fabric Rest to GraphQL

The files in `fabric-rest-2-graphql` folder declare and implement two REST operations on sensors:

#### API Operations

- **GET `/sensors`**: Returns a list of available sensors. This endpoint retrieves sensor records from the underlying Fabric GraphQL API and is typically used to browse or list sensors and their metadata.
- **GET `/sensors/{deviceid}`**: Returns details for a single sensor identified by its `deviceid`. This endpoint looks up a specific sensor and returns its details (for example, timestamp, building identifier, and device identifier). Internally, the REST call is translated into a filtered GraphQL query against the Fabric API.

Both endpoints require an API key provided via the `Ocp-Apim-Subscription-Key` header or query string, as configured in Azure API Management.

#### Test

```bash
cd fabric-rest-2-graphql
azd env get-values > .env
./test-api.sh
```

### Fabric Rest to GraphQL MCP Server

We will utilize the `MCP Servers` APIM feature to present the new `Sensors Rest` API as an MCP (Model Context Protocol) server, allowing an Agent to manage the sensors data.

* APIM > APIs > MCP Servers
* Create MCP Server > Expose an API as MCP Server
* API `Rest to GraphQL Fabric API`
* API Operations : All
* Display Name: `sensors-mcp`


![MCP](./img/mcp-sensors.png)

### The Sensors Agent

Once the `sensors-mcp`sensor available, it's possible to use it with Agents.

#### Github Copilot

* Open `.vscode/mcp.json` Click on Start
* Open `Github Copilot` Side Window and interact with the agent.


## Orders REST API

The files in `orders-rest-api` folder implement a complete REST API for managing orders with full CRUD (Create, Read, Update, Delete) operations.

### Features

- **List Orders**: Get all orders with optional filtering by status and limit
- **Get Order**: Retrieve a specific order by ID
- **Create Order**: Create a new order
- **Update Order**: Update order status, shipping address, or notes
- **Delete Order**: Remove an order from the system
- **Fake Data**: Automatically generates 20 sample orders for testing
- **FastAPI**: Modern Python framework with automatic OpenAPI documentation
- **Pydantic**: Data validation and serialization

### Local Development and Testing

#### Installation

```bash
cd orders-rest-api
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install fastapi uvicorn pydantic
```

#### Running the API

```bash
python main.py
```

The API will be available at `http://localhost:8000`

- Interactive API docs (Swagger UI): `http://localhost:8000/docs`
- Alternative API docs (ReDoc): `http://localhost:8000/redoc`
- OpenAPI schema: `http://localhost:8000/openapi.json`

#### Test

```bash
cd orders-rest-api
./test_api.sh
```

### API Operations

#### List Orders
```bash
GET /orders?status_filter=pending&limit=10
```

Optional query parameters:
- `status_filter`: Filter by status (pending, processing, shipped, delivered, cancelled)
- `limit`: Limit the number of results

#### Get Order by ID
```bash
GET /orders/{order_id}
```

Example:
```bash
curl http://localhost:8000/orders/ORD-2024-001
```

#### Create Order
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

#### Update Order
```bash
PUT /orders/{order_id}
Content-Type: application/json

{
  "status": "processing",
  "notes": "Updated notes"
}
```

#### Delete Order
```bash
DELETE /orders/{order_id}
```

### Order Status Values

- `pending`: Order has been placed but not yet processed
- `processing`: Order is being prepared
- `shipped`: Order has been shipped
- `delivered`: Order has been delivered
- `cancelled`: Order has been cancelled

### Sample Data

The API includes a fake data generator that creates 20 realistic orders with:
- 10 different customers
- 10 different products (laptops, accessories, peripherals)
- Various order statuses based on order age
- Calculated totals (subtotal, tax at 8%, shipping)
- Free shipping for orders over $100

### Deployment with Azure API Management

The Orders API is integrated with Azure API Management. After deploying the infrastructure:

1. Deploy your Orders API backend to Azure (e.g., Azure App Service, Container Apps)
2. Update the `ordersApiBackendUrl` parameter in `infra/main.parameters.json`
3. Run `azd provision` to update the APIM configuration

Access the API through APIM:
```bash
export ORDERS_API_URL=<from azd env>
export ORDERS_APIM_SUBSCRIPTION_KEY=<from azd env>

curl "${ORDERS_API_URL}/orders" \
  -H "Ocp-Apim-Subscription-Key: ${ORDERS_APIM_SUBSCRIPTION_KEY}"
```

## 📚 Additional Resources

- [GitHub GraphQL API Documentation](https://docs.github.com/en/graphql)
- [Azure API Management GraphQL Support](https://docs.microsoft.com/en-us/azure/api-management/graphql-apis-overview)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

