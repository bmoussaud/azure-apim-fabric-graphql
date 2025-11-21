from azure.identity import ClientSecretCredential, InteractiveBrowserCredential, DefaultAzureCredential, AzureCliCredential,AzureDeveloperCliCredential

import requests
import json
 
# Acquire a token
# DO NOT USE IN PRODUCTION.
# Below code to acquire token is for development purpose only to test the GraphQL endpoint
# For production, always register an application in a Microsoft Entra ID tenant and use the appropriate client_id and scopes
# https://learn.microsoft.com/en-us/fabric/data-engineering/connect-apps-api-graphql#create-a-microsoft-entra-app
 
#app = AzureDeveloperCliCredential()
app = ClientSecretCredential(client_id="5dd792f1-e951-4821-afb1-488ecf1868e8",
                             client_secret="xxxxxxx",g
                             tenant_id="be38c437-5790-4e3a-bb56-4811371e35ea")

# Get token for GraphQL API
result = app.get_token('api://5dd792f1-e951-4821-afb1-488ecf1868e8/.default')

print("Access token acquired.")
print(f"Token: {result.token}")  # Print only the first 20 characters for security
 
if not result.token:
    print('Error:', "Could not get access token")
 
# Prepare headers
headers = {
    'Authorization': f'Bearer {result.token}',
    'Content-Type': 'application/json'
}
 
endpoint = 'https://cb0442cc43ea4c819fea0bba9b62f870.zcb.graphql.fabric.microsoft.com/v1/workspaces/cb0442cc-43ea-4c81-9fea-0bba9b62f870/graphqlapis/64f58335-5d12-441d-b5e5-51778048a084/graphql'
query = """
    query {
  factory_iot_datas(first: 10) {
     items {
        Timestamp
        DeviceID
     }
  }
}
"""


test_query = """
    query {
      __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
          name
          kind
          description
        }
      }
    }
    """
 
variables = {
 
  }

print(query)
print(endpoint)
 
# Issue GraphQL request
try:
    print(f"Making request to: {endpoint}")
    print(f"Headers: {dict((k, v[:50] + '...' if len(str(v)) > 50 else v) for k, v in headers.items())}")
    response = requests.post(endpoint, json={'query': query, 'variables': variables}, headers=headers)
    
    print(f"Response status code: {response.status_code}")
    print(f"Response headers: {dict(response.headers)}")
    
    if response.status_code == 404:
        print("\n404 Error: This could indicate:")
        print("1. The GraphQL endpoint URL is incorrect")
        print("2. The workspace ID or GraphQL API ID in the URL is wrong")
        print("3. The API might not be published or accessible")
        print("4. Authentication scope might be incorrect")
        print("\nPlease verify the endpoint URL in the Fabric portal")
    
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