targetScope = 'resourceGroup'

@sys.description('Service name')
param cognitiveServiceName string

@sys.description('Service SKU. NOTE: S0 is currently the only supported SKU.')
param cognitiveServiceSku string

@sys.description('Location of the resource.')
param resourceLocation string

// Deployment name variables
var deploymentNames = {
  cognitiveService: 'st-kt-aoi-srv'
}

module cognitiveService '../az-modules/Microsoft.CognitiveServices/accounts/deploy.bicep' = {
  name: deploymentNames.cognitiveService
  params: {
    cognitiveServiceName: cognitiveServiceName
    location: resourceLocation
    sku: cognitiveServiceSku
  }
}
