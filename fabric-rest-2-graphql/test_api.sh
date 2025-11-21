#!/usr/bin/env bash

set -euo pipefail

# Load environment variables from .env if present
if [ -f "../.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' ../.env | xargs)
fi

# We expect:
#   FABRIC_REST_API_URL                -> base URL of the REST-to-GraphQL API in APIM
#   FABRIC_REST_APIM_SUBSCRIPTION_KEY  -> APIM subscription key for REST facade

if [ -z "${FABRIC_REST_API_URL:-}" ] || [ -z "${FABRIC_REST_APIM_SUBSCRIPTION_KEY:-}" ]; then
  echo "FABRIC_REST_API_URL and FABRIC_REST_APIM_SUBSCRIPTION_KEY must be set in ../.env" >&2
  exit 1
fi

# Strip trailing slash if any
FABRIC_REST_TO_GRAPHQL_API_URL="${FABRIC_REST_API_URL%/}"

echo "Using FABRIC_REST_TO_GRAPHQL_API_URL: ${FABRIC_REST_TO_GRAPHQL_API_URL}"
set -x
echo "Calling GET /sensors (list all sensors)"
curl -sS -X GET "${FABRIC_REST_TO_GRAPHQL_API_URL}/sensors" \
  -H "Ocp-Apim-Subscription-Key: ${FABRIC_REST_APIM_SUBSCRIPTION_KEY}" \
  -H "Accept: application/json" | jq .

echo
echo "Calling GET /sensors/{deviceid} (fetch second sensor detail)"

# Fetch list once to derive the second device id
DEVICE_ID=$(
  curl -sS -X GET "${FABRIC_REST_TO_GRAPHQL_API_URL}/sensors" \
    -H "Ocp-Apim-Subscription-Key: ${FABRIC_REST_APIM_SUBSCRIPTION_KEY}" \
    -H "Accept: application/json" | jq -r '.sensors[1].DeviceID'
)

if [ -z "${DEVICE_ID}" ] || [ "${DEVICE_ID}" = "null" ]; then
  echo "Unable to determine second sensor DeviceID from /sensors response" >&2
  exit 1
fi

curl -sS -X GET "${FABRIC_REST_TO_GRAPHQL_API_URL}/sensors/${DEVICE_ID}" \
  -H "Ocp-Apim-Subscription-Key: ${FABRIC_REST_APIM_SUBSCRIPTION_KEY}" \
  -H "Accept: application/json" | jq .