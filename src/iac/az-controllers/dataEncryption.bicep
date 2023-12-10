targetScope = 'resourceGroup'

@sys.description('Main Key Vault name')
param dataEncryptionVaultName string

@sys.description('Location of the resource.')
param resourceLocation string

// Deployment name variables
var deploymentNames = {
  dataEncryptionKeyVault: 'data-encryption-kv-module'
}

module dataEncryptionVault '../az-modules/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: deploymentNames.dataEncryptionKeyVault
  params: {
    name: dataEncryptionVaultName
    location: resourceLocation
  }
}

resource existingDataEncryptionVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: dataEncryptionVaultName
}

resource aoiDataEncryptionKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  name: 'aoiDataEncryptionKey'
  parent: existingDataEncryptionVault
  properties: {
    attributes: {
      enabled: true
    }
    keySize: 4096
    kty: 'RSA'
  }
}
