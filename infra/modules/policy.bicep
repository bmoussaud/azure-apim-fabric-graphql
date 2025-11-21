/**
 * @module policy-v1
 * @description This module defines the API resources using Bicep.
 * It includes configurations for creating and managing APIs, products, and policies.
 */
@description('The name of the API Management instance. Defaults to "apim-<resourceSuffix>".')
param apimName string

@description('The name of the api')
param apiName string  

@description('The operation name for the API.')
param operationName string 

@description('The API configuration object.')
param policyXml string = ''

// https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service
resource apimService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis
resource apimApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  name: apiName
  parent: apimService
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2022-04-01-preview' existing = {
  name: operationName
  parent: apimApi
}


// NEW: operation-level policy
resource operationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-04-01-preview' = {
  name: 'policy'
  parent: operation
  properties: {
    format: 'rawxml'
    value: policyXml
  }
}



