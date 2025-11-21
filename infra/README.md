# Azure API Management Infrastructure

This folder contains Bicep templates for deploying Azure API Management (APIM) with Application Insights integration and a GitHub GraphQL API configuration.

## Architecture

The infrastructure includes:

- **Azure API Management**: A fully managed API gateway with Basicv2 tier configuration
- **Application Insights**: Monitoring and diagnostics for the API Management instance
- **Log Analytics Workspace**: Centralized logging and monitoring workspace
- **GitHub GraphQL API**: Pre-configured GraphQL API for GitHub API access with custom policies

## Files

- `main.bicep`: Main orchestration template that deploys all resources
- `main.parameters.json`: Parameters file with environment and GitHub token configuration
- `modules/api-management.bicep`: Azure API Management module
- `modules/app-insights.bicep`: Application Insights module
- `modules/log-analytics-workspace.bicep`: Log Analytics workspace module
- `modules/graphql-api.bicep`: GitHub GraphQL API configuration module

## Prerequisites

- Azure CLI installed ([Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- An Azure subscription
- Appropriate permissions to create resources in Azure

## Deployment

### 1. Login to Azure

```bash
az login
```

### 2. Set your subscription (if you have multiple)

```bash
az account set --subscription <subscription-id>
```

### 3. Create a resource group

```bash
az group create --name rg-apim-graphql --location eastus
```

### 4. Deploy the infrastructure

Update the `main.parameters.json` file with your environment name and GitHub token, then deploy:

```bash
az deployment group create \
  --resource-group rg-apim-graphql \
  --template-file main.bicep \
  --parameters main.parameters.json
```

Or deploy with inline parameters:

```bash
az deployment group create \
  --resource-group rg-apim-graphql \
  --template-file main.bicep \
  --parameters environmentName=dev \
               githubToken=your_github_personal_access_token
```

## Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `location` | Azure region for deployment | Resource Group location | No |
| `environmentName` | Name of the environment (used to generate unique resource names) | - | Yes |
| `githubToken` | GitHub Personal Access Token for GraphQL API access | - | Yes |
| `tags` | Tags to apply to all resources | Environment and ManagedBy tags | No |

## Outputs

After deployment, the following outputs will be available:

- `APIM_NAME`: Name of the API Management instance
- `APIM_GATEWAY_URL`: Gateway URL for the API Management instance
- `GITHUB_APIM_SUBSCRIPTION_KEY`: Subscription key for accessing the GitHub GraphQL API
- `GITHUB_GRAPHQL_API_URL`: Complete URL for accessing the GitHub GraphQL API through APIM
- `OAUTH_TENANT_ID`: Azure tenant ID for OAuth scenarios
- `SUBSCRIPTION_ID`: Azure subscription ID
- `GITHUB_TOKEN`: GitHub token (for reference)

## Configuration

### API Management

- **SKU**: Basicv2 (configurable via code)
- **Capacity**: 1 unit (configurable via code)
- **Identity**: System-assigned managed identity enabled
- **Monitoring**: Integrated with Application Insights
- **Publisher**: "GraphQL Apps" organization
- **Email**: Environment-based email (e.g., dev@contososuites.com)

### Application Insights

- **Type**: Web application
- **Integration**: Connected to Log Analytics workspace
- **Monitoring**: API Management integration for comprehensive telemetry

### Log Analytics Workspace

- **Purpose**: Centralized logging and monitoring
- **Integration**: Connected to Application Insights for unified monitoring

### GitHub GraphQL API

- **Path**: `/github-graphql`
- **Service URL**: `https://api.github.com/graphql`
- **Authentication**: Uses provided GitHub Personal Access Token
- **Policies**: Custom XML policy for request/response handling
- **Schema**: Pre-loaded GraphQL schema for GitHub API
- **Subscription**: Required for API access

## Customization

### Change Environment Name

Edit `main.parameters.json`:

```json
{
  "environmentName": {
    "value": "production"
  }
}
```

### Update GitHub Token

Edit `main.parameters.json`:

```json
{
  "githubToken": {
    "value": "your_new_github_token"
  }
}
```

### Modify APIM Configuration

Edit the API Management module parameters in `main.bicep` to change:
- SKU name (e.g., from "Basicv2" to "Standard")
- SKU count for scaling
- Publisher information

## Clean Up

To delete all deployed resources:

```bash
az group delete --name rg-apim-graphql --yes --no-wait
```

## Notes

- API Management provisioning can take 30-45 minutes
- Basicv2 tier provides essential features suitable for development and testing
- GitHub Personal Access Token is required for accessing GitHub's GraphQL API
- Application Insights integration provides comprehensive monitoring and diagnostics
- System-assigned managed identity is enabled for secure access to other Azure resources
- The GitHub GraphQL API is pre-configured with custom policies and schema

## Next Steps

After deployment:

1. Access the API Management portal using the gateway URL from outputs
2. Test the GitHub GraphQL API using the provided subscription key
3. Monitor API usage and performance in Application Insights
4. Customize the GraphQL policies in the `github-graphql-sample` folder as needed
5. Set up additional security features (OAuth, JWT validation, etc.)
6. Configure rate limiting and throttling policies
