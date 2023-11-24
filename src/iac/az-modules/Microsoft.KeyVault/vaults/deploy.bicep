targetScope = 'resourceGroup'

@maxLength(24)
@description('KeyVault name')
param name string

@maxLength(128)
@description('KeyVault location')
param location string

@description('KeyVault authentication tenant id')
param tenantId string

@description('Name of the secret')
param secretName string

@description('Name of the existing Cognitive Service')
@secure()
param secretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    enableSoftDelete: false
    accessPolicies: []
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: secretValue
  }
}
