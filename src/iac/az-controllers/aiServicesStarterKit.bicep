targetScope = 'resourceGroup'

@sys.description('Key Vault name')
param keyVaultName string

@sys.description('Authentication tenant for the Key Vault')
param tenantId string = tenant().tenantId

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
  roleAssignments: 'starter-kit-assignments-module'
}

module cognitiveService '../az-modules/Microsoft.CognitiveServices/accounts/deploy.bicep' = {
  name: deploymentNames.cognitiveService
  dependsOn: [
    searchService
    storageAccount
  ]
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

// Get a reference to the existing CognitiveServices account
// This is needed to securely provide the key to the Key Vault resource
resource existingSearchService 'Microsoft.Search/searchServices@2020-08-01' existing = {
  name: searchName
}

// resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
//   name: storageAccountName
// }

module keyVault '../az-modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: deploymentNames.keyVault
  dependsOn: [
    searchService
    storageAccount
    cognitiveService
  ]
  params: {
    name: keyVaultName
    location: resourceLocation
    tenantId: tenantId
    objectId: objectId
    cognitiveServiceSecretName: 'cognitive-service-key'
    cognitiveServiceSecretValue: existingCognitiveService.listKeys().key1
    // searchServiceSecretName: 'search-service-key'
    // searchServiceSecretValue: existingSearchService.listAdminKeys().primaryKey
    // storageAccountSecretName: 'storage-account-connection-string'
    // storageAccountSecretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${existingStorageAccount.listKeys().keys[0].value}'
  }
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
}

module roleAssignments '../az-modules/Microsoft.Authorization/roleAssignments/deploy.bicep' = {
  name: deploymentNames.roleAssignments
  params: {
    principalId: '222d2893-01fb-4bec-ba76-62dc60e6af92'
    roleDefinitions: [
      'Cognitive Services Contributor'
      'Cognitive Services OpenAI Contributor'
    ]
    principalType: 'User'
  }
}
