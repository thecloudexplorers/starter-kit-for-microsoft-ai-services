targetScope = 'resourceGroup'

@sys.description('Main Key Vault name')
param mainVaultName string

@sys.description('Main Key Vault name')
param dataEncryptionVaultName string

@sys.description('Encryptionkey name')
param dataEncryptionKeyName string

@sys.description('Encryptionkey version')
param dataEncryptionKeyVersion string

@description('My users object id')
param theCloudExplorerUserObjectId string

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
  mainKeyVault: 'starter-kit-main-kv-module'
  storageAccount: 'starter-kit-sa-module'
  searchService: 'starter-kit-search-module'
}

module cognitiveService '../az-modules/Microsoft.CognitiveServices/accounts/deploy.bicep' = {
  name: deploymentNames.cognitiveService
  params: {
    keyName: dataEncryptionKeyName
    keyVersion: dataEncryptionKeyVersion
    keyVaultUri: existingDataEncryptionVault.properties.vaultUri
    cognitiveServiceName: cognitiveServiceName
    location: resourceLocation
    sku: cognitiveServiceSku
  }
}

module mainVault '../az-modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: deploymentNames.mainKeyVault
  params: {
    name: mainVaultName
    location: resourceLocation
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
    storageAccount
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

resource existingMainVaultName 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: mainVaultName
}

resource existingDataEncryptionVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: dataEncryptionVaultName
}

// Experimental, needs more research
// resource existingDataEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' existing = {
//   name: dataEncryptionKeyName
// }

// resource existingDataEncryptionKeyVersion 'Microsoft.KeyVault/vaults/keys/versions@2022-07-01' existing = {
//   name: dataEncryptionKeyName
// }

resource cognitiveServiceSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: existingMainVaultName
  name: 'cognitive-service-key'
  properties: {
    value: existingCognitiveService.listKeys().key1
  }
}

resource searchServiceSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: existingMainVaultName
  name: 'search-service-key'
  properties: {
    value: existingSearchService.listAdminKeys().primaryKey
  }
}

resource storageAccountSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: existingMainVaultName
  name: 'storage-account-connection-string'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${existingStorageAccount.listKeys().keys[0].value}'
  }
}

resource theCloudExplorerPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: existingMainVaultName
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
        objectId: theCloudExplorerUserObjectId
      }
    ]
  }
}

resource cognitiveServicePolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: existingDataEncryptionVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'unwrapKey'
            'wrapKey'
            'get'
          ]
        }
        objectId: existingCognitiveService.identity.principalId
      }
    ]
  }
  dependsOn: [
    cognitiveService
  ]
}
