

1. Create an entra Id Apps `fabric-graphql-app`

* Application (client) ID: 5dd792f1-e951-4821-afb1-488ecf1868e8
* Directory (tenant) ID: be38c437-5790-4e3a-bb56-4811371e35ea

2. add API Permission: Power BI Service, Delegated permissions, GraphQLApi.Execute.All

![API Permission](images/Fabric%20GraphQL%20API%20Permission.png)

3. Expose an API, scope `api://5dd792f1-e951-4821-afb1-488ecf1868e8` 
* Scope Name: graphql
* Admin & Users
* Admin|User consent display name: Fabric GraphQL API
* Admin|User consent description: Fabric GraphQL API
* State Enabled

![ExposeAPI](images/Fabric%20GraphQL%20Expose%20API.png)

4. Create a Client Secret
![Client Secret](images/Fabric%20GraphQL%20Client%20Secret.png)

## References

https://learn.microsoft.com/en-us/fabric/data-engineering/connect-apps-api-graphql#create-a-microsoft-entra-app
https://learn.microsoft.com/en-us/fabric/data-engineering/api-graphql-azure-api-management
