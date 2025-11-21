@description('Name of the container app')
param containerAppName string

@description('Location for resources')
param location string = resourceGroup().location

@description('Container Apps environment ID')
param environmentId string

@description('User identity IDs for the container app.')
param acrPullRoleName string = ''

@description('Container port')
param containerPort int = 8000

@description('CPU cores')
param cpu string = '0.5'

@description('Memory in Gi')
param memory string = '1.0Gi'

@description('Minimum replicas')
param minReplicas int = 1

@description('Maximum replicas')
param maxReplicas int = 10

@description('Environment variables for the container')
param environmentVariables array = []

@description('Enable ingress')
param ingressEnabled bool = true

@description('Enable external ingress')
param externalIngress bool = true

@description('Azure Container Registry name.')
param containerRegistryName string

param isLatestImageExist bool = false

module fetchLatestImage 'fetch-container-image.bicep' = {
  name: '${containerAppName}-fetch-image'
  params: {
    exists: isLatestImageExist
    name: containerAppName
  }
}

resource uaiAcrPull 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: acrPullRoleName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: containerRegistryName
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: { 'azd-service-name': containerAppName }
   identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uaiAcrPull.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      registries: [
        {
          identity: uaiAcrPull.id
          server: containerRegistry.properties.loginServer
        }
      ]
      ingress: ingressEnabled ? {
        external: externalIngress
        targetPort: containerPort
        transport: 'http'
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      } : null
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          env: environmentVariables
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

output containerAppUrl string = ingressEnabled ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''
output containerAppFqdn string = ingressEnabled ? containerApp.properties.configuration.ingress.fqdn : ''
output containerAppName string = containerApp.name
