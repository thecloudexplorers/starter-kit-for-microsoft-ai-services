targetScope = 'resourceGroup'

@maxLength(24)
@description('KeyVault name')
param name string

@maxLength(128)
@description('KeyVault location')
param location string

@description('KeyVault authentication tenant id')
param tenantId string

@description('My users object id')
param objectId string

@description('Name of the cognitive service secret')
param cognitiveServiceSecretName string

@description('Value of the cognitive service secret')
@secure()
param cognitiveServiceSecretValue string

// @description('Name of the search service secret')
// param searchServiceSecretName string

// @description('Value of the search service secret')
// @secure()
// param searchServiceSecretValue string

// @description('Name of the storage account secret')
// param storageAccountSecretName string

// @description('Value of the storage account secret')
// @secure()
// param storageAccountSecretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enableSoftDelete: false
    accessPolicies: [
      // {
      //   objectId: objectId
      //   tenantId: tenant().tenantId
      //   permissions: {
      //     secrets: [
      //       'all'
      //     ]
      //   }
      // }
    ]
  }
}

resource cognitiveServiceSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: cognitiveServiceSecretName
  properties: {
    value: cognitiveServiceSecretValue
  }
}

// resource searchServiceSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: keyVault
//   name: searchServiceSecretName
//   properties: {
//     value: searchServiceSecretValue
//   }
// }

// resource storageAccountSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   parent: keyVault
//   name: storageAccountSecretName
//   properties: {
//     value: storageAccountSecretValue
//   }
// }
