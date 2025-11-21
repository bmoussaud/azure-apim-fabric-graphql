@description('The location where resources will be deployed')
param location string = resourceGroup().location

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string



@description('Fabric GraphQL Endpoint URL')
param fabricGraphQLEndpoint string = 'https://path-to-fabric-graphql-endpoint/graphql'


@description('Tags to apply to all resources')
param tags object = {
  Environment: environmentName
  ManagedBy: 'Bicep'
}

#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(resourceGroup().id, environmentName, location))

resource apimManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: 'apim-mi-${resourceToken}'
  location: location
}

resource uaiAcrPull 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: 'acr-pull'
  location: location
}

@description('This allows the managed identity of the container app to access the registry, note scope is applied to the wider ResourceGroup not the ACR')
resource uaiRbacAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uaiAcrPull.id, 'ACR Pull Role RG')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: uaiAcrPull.properties.principalId
    principalType: 'ServicePrincipal'
  }
}


module applicationInsights 'modules/app-insights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
    workspaceName: logAnalyticsWorkspace.outputs.name
    applicationInsightsName: 'app-insights-${resourceToken}'
    tags: tags
  }
}

module logAnalyticsWorkspace 'modules/log-analytics-workspace.bicep' = {
  name: 'log-analytics-workspace'
  params: {
    location: location
    logAnalyticsName: 'log-analytics-${resourceToken}'
    tags: tags
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acr${resourceToken}'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: tags
}

module containerAppsEnvironment 'modules/container-apps-environment.bicep' = {
  name: 'container-apps-environment'
  params: {
    environmentName: 'cae-${resourceToken}'
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    tags: tags
  }
}

module ordersRestApiContainerApp 'modules/container-app.bicep' =  {
  name: 'orders-rest-api-container-app'
  params: {
    containerAppName: 'orders-rest-api'
    location: location
    environmentId: containerAppsEnvironment.outputs.environmentId
    containerPort: 8000
    cpu: '0.5'
    memory: '1.0Gi'
    ingressEnabled: true
    externalIngress: true
    containerRegistryName: containerRegistry.name
    acrPullRoleName: uaiAcrPull.name
  }
}

module apiManagement 'modules/api-management.bicep' = {
  name: 'api-management'
  params: {
    location: location
    tags: tags
    serviceName: 'apim-${resourceToken}'
    publisherName: 'GraphQL Apps'
    publisherEmail: '${environmentName}@contososuites.com'
    skuName: 'Basicv2'
    skuCount: 1
    aiName: applicationInsights.outputs.aiName
    managedIdentityResourceId: apimManagedIdentity.id
  }
}



module fabricGraphqlApi 'modules/graphql-api.bicep' = {
  name: 'fabric-graphql-api'
  params: {
    apimName: apiManagement.outputs.name
    appInsightsId: applicationInsights.outputs.aiId
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    
    api: {
      name: 'fabric-graphql-api'
      description: 'Fabric Factory GraphQL API'
      displayName: 'Fabric Factory GraphQL API'
      path: '/fabric-graphql'
      serviceUrl: fabricGraphQLEndpoint
      subscriptionRequired: true
      tags: ['fabric', 'api', 'graphql','factory']
      policyXml: loadTextContent('../fabric-graphql/fabric-graphql-policy.xml')
      schema: loadTextContent('../fabric-graphql/factory_schema.graphql')
      namedValues: {
        managed_identity_client_id: apimManagedIdentity.properties.clientId
      }
      secretNamedValues: {}
    }
    
  }
}

module fabricbRest2GraphqlApi 'modules/api.bicep' = {
  name: 'fabric-rest-to-graphql-api'
  params: {
    apimName: apiManagement.outputs.name
    appInsightsId: applicationInsights.outputs.aiId
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    
    api: {
      name: 'fabric-rest-to-graphql-api'
      description: 'Rest to GraphQL Fabric API'
      displayName: 'Rest to GraphQL Fabric API'
      path: '/fabric-rest-to-graphql'
      serviceUrl: fabricGraphQLEndpoint
      subscriptionRequired: true
      tags: ['fabric', 'api', 'rest','factory']
      policyXml: loadTextContent('../fabric-rest-2-graphql/fabric-rest-to-graphql-policy-base.xml')
      value: loadTextContent('../fabric-rest-2-graphql/swagger.json')
      namedValues: {
        managedIdentityClientId: apimManagedIdentity.properties.clientId
        fabric_graphql_endpoint: endsWith(fabricGraphQLEndpoint, '/graphql') ? substring(fabricGraphQLEndpoint, 0, length(fabricGraphQLEndpoint) - 8) : fabricGraphQLEndpoint
      }
      secretNamedValues: {}
    }
    
  }
}

module sensorsOperation 'modules/policy.bicep' = {
  name: 'sensors-operation-policy'
  params: {
    apimName: apiManagement.outputs.name
    apiName: fabricbRest2GraphqlApi.outputs.apiName 
    operationName: 'sensors'
    policyXml: loadTextContent('../fabric-rest-2-graphql/fabric-rest-to-graphql-policy-base-sensors.xml')
  }
}

module sensorDetailOperation 'modules/policy.bicep' = {
  name: 'sensor-operation-policy'
  params: {
    apimName: apiManagement.outputs.name
    apiName: fabricbRest2GraphqlApi.outputs.apiName
    operationName: 'sensor'
    policyXml: loadTextContent('../fabric-rest-2-graphql/fabric-rest-to-graphql-policy-base-sensors-details.xml')
  }
}

module ordersApi 'modules/api.bicep' = {
  name: 'orders-api'
  params: {
    apimName: apiManagement.outputs.name
    appInsightsId: applicationInsights.outputs.aiId
    appInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    
    api: {
      name: 'orders-api'
      description: 'Orders Management REST API'
      displayName: 'Orders REST API'
      path: '/orders-api'
      serviceUrl: ordersRestApiContainerApp!.outputs.containerAppUrl 
      acrPullRoleName: uaiAcrPull.name
      subscriptionRequired: true
      tags: ['orders', 'api', 'rest']
      policyXml: loadTextContent('../orders-rest-api/orders-api-policy.xml')
      value: loadTextContent('../orders-rest-api/orders-api-swagger.json')
      namedValues: {
        ordersApiKey: '1111-22222-33333-44444'
      }
      secretNamedValues: {}
    }
  }
}

output APIM_GATEWAY_URL string = apiManagement.outputs.apiManagementProxyHostName
output APIM_NAME string = apiManagement.outputs.name
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.properties.loginServer
output FABRIC_ENDPOINT string = fabricGraphQLEndpoint
output FABRIC_GRAPHQL_API_URL string = 'https://${apiManagement.outputs.apiManagementProxyHostName}/${fabricGraphqlApi.outputs.apiPath}'
output FABRIC_GRAPQL_APIM_SUBSCRIPTION_KEY string = fabricGraphqlApi.outputs.subscriptionPrimaryKey
output FABRIC_MCP_ENDPOINT string = 'https://${apiManagement.outputs.apiManagementProxyHostName}/sensors-mcp/mcp'
output FABRIC_REST_API_URL string = 'https://${apiManagement.outputs.apiManagementProxyHostName}/${fabricbRest2GraphqlApi.outputs.apiPath}'
output FABRIC_REST_APIM_SUBSCRIPTION_KEY string = fabricbRest2GraphqlApi.outputs.subscriptionPrimaryKey

output OAUTH_TENANT_ID string = tenant().tenantId
output SUBSCRIPTION_ID string = subscription().subscriptionId
output ORDERS_API_URL string = 'https://${apiManagement.outputs.apiManagementProxyHostName}/${ordersApi.outputs.apiPath}'
output ORDERS_APIM_SUBSCRIPTION_KEY string = ordersApi.outputs.subscriptionPrimaryKey
output ORDERS_CONTAINER_APP_URL string = ordersRestApiContainerApp!.outputs.containerAppUrl 
output ORDERS_CONTAINER_APP_FQDN string = ordersRestApiContainerApp!.outputs.containerAppFqdn 
