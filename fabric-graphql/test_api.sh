#!/bin/bash
# Quick test script for Microsoft Fabric GraphQL API

echo "Getting access token..."

azd env get-values > .env
source .env

echo "Access token acquired. ${FABRIC_ACCESS_TOKEN:0:20}... (truncated)"
echo "Testing endpoint..."

# Test 1: Schema introspection query
SCHEMA_QUERY='query { __schema { queryType { name } types { name kind } } }'
echo "Testing schema introspection..."
curl -X POST "$FABRIC_GRAPHQL_API_URL" \
  -H "Ocp-Apim-Subscription-Key: ${FABRIC_GRAPQL_APIM_SUBSCRIPTION_KEY}"  \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$SCHEMA_QUERY\"}" \
  -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n"

echo -e "\n---\n"

# Test 2: Valid query using available schema
QUERY='query { factory_iot_datas(first: 10) { items { Timestamp BuildingID DeviceID Location MetricType Value Unit Status } hasNextPage endCursor } }'
echo "Testing legrand_iot_datas query..."
curl -X POST "$FABRIC_GRAPHQL_API_URL" \
  -H "Ocp-Apim-Subscription-Key: ${FABRIC_GRAPQL_APIM_SUBSCRIPTION_KEY}"  \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$QUERY\"}" \
  -w "\nHTTP Status: %{http_code}\nTime: %{time_total}s\n" \
  -v