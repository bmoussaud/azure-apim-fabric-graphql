from azure.identity import ClientSecretCredential, InteractiveBrowserCredential, DefaultAzureCredential, AzureCliCredential,AzureDeveloperCliCredential

import requests
import json
import os
from dotenv import load_dotenv
 
load_dotenv()  # Load environment variables from .env file

fabricEndpoint = os.getenv("FABRIC_GRAPHQL_API_URL")
apim_subscription_key = os.getenv("FABRIC_APIM_SUBSCRIPTION_KEY")

if not fabricEndpoint or not apim_subscription_key:
    raise ValueError("FABRIC_GRAPHQL_API_URL and FABRIC_APIM_SUBSCRIPTION_KEY must be set in environment variables.")

# Prepare headers
headers = {
    'Content-Type': 'application/json',
    'Ocp-Apim-Subscription-Key': apim_subscription_key
}
 
query = """
query {
  factory_iot_datas(first: 10) {
     items {
        Timestamp
        BuildingID
        DeviceID

     }
  }
}
"""

variables = {
 
  }

print(f"Using FABRIC_GRAPHQL_API_URL: {fabricEndpoint}")
print(query)

 
# Issue GraphQL request
try:
    print(f"Making request to: {fabricEndpoint}")
    print(f"Headers: {dict((k, v[:50] + '...' if len(str(v)) > 50 else v) for k, v in headers.items())}")
    response = requests.post(fabricEndpoint, json={'query': query, 'variables': variables}, headers=headers)
    
    print(f"Response status code: {response.status_code}")
    print(f"Response headers: {dict(response.headers)}")
    response.raise_for_status()
    data = response.json()
    print(json.dumps(data, indent=4))
except requests.exceptions.HTTPError as http_error:
    print(f"HTTP Error: {http_error}")
    if hasattr(response, 'text'):
        print(f"Response content: {response.text}")
    raise http_error
except Exception as error:
    print(f"Query failed with error: {error}")
    raise error