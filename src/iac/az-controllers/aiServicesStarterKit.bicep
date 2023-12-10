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

@sys.description('Sku of the storage account')
param storageAccountSku string

@sys.description('Sku of the storage account')
param storageAccountName string

@sys.description('Search service name')
param searchName string

@sys.description('Search service sku')
param searchSku string

@sys.description('Replicas distribute search workloads across the service.')
param searchReplicaCount int

@sys.description('Partitions allow for scaling of document count.')
param searchPartitionCount int

// Deployment name variables
var deploymentNames = {
  cognitiveService: 'starter-kit-aoi-module'
  keyVault: 'starter-kit-kv-module'
  storageAccount: 'starter-kit-sa-module'
  searchService: 'starter-kit-search-module'
}

module cognitiveService '../az-modules/Microsoft.CognitiveServices/accounts/deploy.bicep' = {
  name: deploymentNames.cognitiveService
  params: {
    keyName: 'aoiEncryptionKey'
    keyVersion: '3c55b384fbdd4e31a6795ae3d19596f1'
    keyVaultUri: 'https://dgs-s-cgs-kv002.vault.azure.net/'
    cognitiveServiceName: cognitiveServiceName
    location: resourceLocation
    sku: cognitiveServiceSku
  }
}

module keyVault '../az-modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: deploymentNames.keyVault
  params: {
    name: keyVaultName
    location: resourceLocation
    tenantId: tenantId
    objectId: objectId
    cognitiveServiceSecretName: 'cognitive-service-key'
    cognitiveServiceSecretValue: existingCognitiveService.listKeys().key1
    searchServiceSecretName: 'search-service-key'
    searchServiceSecretValue: existingSearchService.listAdminKeys().primaryKey
    storageAccountSecretName: 'storage-account-connection-string'
    storageAccountSecretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${existingStorageAccount.listKeys().keys[0].value}'
  }
  dependsOn: [
    cognitiveService
    searchService
    storageAccount
  ]
}

module storageAccount '../az-modules/Microsoft.Storage/storageaccounts/deploy.bicep' = {
  name: deploymentNames.storageAccount
  params: {
    storageAccountName: storageAccountName
    location: resourceLocation
    sku: storageAccountSku
  }
}

module searchService '../az-modules/Microsoft.Search/searchServices/deploy.bicep' = {
  name: deploymentNames.searchService
  params: {
    name: searchName
    location: resourceLocation
    sku: searchSku
    replicaCount: searchReplicaCount
    partitionCount: searchPartitionCount
  }
  dependsOn: [
    cognitiveService
  ]
}

// Get a reference to the existing CognitiveServices account
// This is needed to securely provide the key to the Key Vault resource
resource existingCognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: cognitiveServiceName
}

// Get a reference to the existing CognitiveServices account
// This is needed to securely provide the key to the Key Vault resource
resource existingSearchService 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: searchName
}

resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}
