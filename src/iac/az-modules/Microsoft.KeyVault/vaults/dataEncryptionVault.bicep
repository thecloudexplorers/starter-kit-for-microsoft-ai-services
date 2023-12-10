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
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
    ]
  }
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    keySize: 4096
    kty: 'RSA'
  }
}
