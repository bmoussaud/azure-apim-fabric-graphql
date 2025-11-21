from azure.identity import InteractiveBrowserCredential, DefaultAzureCredential, AzureCliCredential,AzureDeveloperCliCredential

import requests
import json
 
# Acquire a token
# DO NOT USE IN PRODUCTION.
# Below code to acquire token is for development purpose only to test the GraphQL endpoint
# For production, always register an application in a Microsoft Entra ID tenant and use the appropriate client_id and scopes
# https://learn.microsoft.com/en-us/fabric/data-engineering/connect-apps-api-graphql#create-a-microsoft-entra-app
 
#app = AzureDeveloperCliCredential(tenant_id="de0dfa5c-3de9-4321-90aa-13727d0ca0b4")
app = InteractiveBrowserCredential()
scp = 'https://analysis.windows.net/powerbi/api/user_impersonation'
result = app.get_token(scp)
print("Access token acquired.")
print(f"Token: {result.token}...")  # Print only the first 20 characters for security
 
if not result.token:
    print('Error:', "Could not get access token")
 
# Prepare headers
headers = {
    'Authorization': f'Bearer {result.token}',
    'Content-Type': 'application/json'
}
 
endpoint = 'https://f8266fef6a6b42e7aed3e2c8d8b4ab75.zf8.graphql.fabric.microsoft.com/v1/workspaces/f8266fef-6a6b-42e7-aed3-e2c8d8b4ab75/graphqlapis/245e939b-f666-40db-8d53-be4996c1030b/graphql'
endpoint='https://apim-tgebslojbs6y2.azure-api.net/fabric-graphql'
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
    response = requests.post(endpoint, json={'query': query, 'variables': variables}, headers=headers)
    response.raise_for_status()
    data = response.json()
    print(json.dumps(data, indent=4))
except Exception as error:
    print(f"Query failed with error: {error}")
    raise error