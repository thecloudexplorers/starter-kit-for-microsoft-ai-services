targetScope = 'resourceGroup'

@sys.description('Key Vault name')
param keyVaultName string

@sys.description('Authentication tenant for the Key Vault')
param tenantId string

@description('My users object id')
param objectId string

@sys.description('Service name')
param cognitiveServiceName string

@sys.description('Service SKU. NOTE: S0 is currently the only supported SKU.')
param cognitiveServiceSku string

@sys.description('Location of the resource.')
param resourceLocation string

// Deployment name variables
var deploymentNames = {
  cognitiveService: 'starter-kit--aoi-module'
  keyVault: 'starter-kit-kv-module'
}

module cognitiveService '../az-modules/Microsoft.CognitiveServices/accounts/deploy.bicep' = {
  name: deploymentNames.cognitiveService
  params: {
    cognitiveServiceName: cognitiveServiceName
    location: resourceLocation
    sku: cognitiveServiceSku
  }
}

// Get a reference to the existing CognitiveServices account
// This is needed to securely provide the key to the Key Vault resource
resource existingCognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: cognitiveServiceName
}

module keyVault '../az-modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: deploymentNames.keyVault
  params: {
    name: keyVaultName
    location: resourceLocation
    tenantId: tenantId
    objectId: objectId
    secretName: 'cognitive-service-key'
    secretValue: existingCognitiveService.listKeys().key1
  }
}
