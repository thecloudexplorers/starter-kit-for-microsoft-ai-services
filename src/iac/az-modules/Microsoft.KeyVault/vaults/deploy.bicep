targetScope = 'resourceGroup'

@maxLength(24)
@description('KeyVault name')
param name string

@maxLength(128)
@description('KeyVault location')
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    tenantId: subscription().tenantId
    // Not allowing to purge key vault or its objects after deletion
    enablePurgeProtection: true
    enableSoftDelete: true
    // Already present, as of such gives errors, fixc later
    //softDeleteRetentionInDays: 7
  }
}
