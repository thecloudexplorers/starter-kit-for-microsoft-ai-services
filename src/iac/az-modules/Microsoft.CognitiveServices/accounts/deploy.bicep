@description('That name is the name of the service')
param cognitiveServiceName string

@description('Location for all resources.')
@allowed([
  'East US'
  'Sweden Central'
])
param location string

@allowed([
  'S0'
])
param sku string

@description('Name of the encryption key')
param keyName string

@description('Key Vault URI')
param keyVaultUri string

@description('Version of the encryption key')
param keyVersion string

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServiceName
  location: location
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: cognitiveServiceName
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyVaultProperties: {
        keyName: keyName
        keyVaultUri: keyVaultUri
        keyVersion: keyVersion
      }
    }
  }
}

resource oaiGpt35TurboDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: cognitiveService
  name: 'oai-gpt-35-turbo-1106'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '1106' // gpt-35-turbo version 0613 will be used
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable' //NoAutoUpgrade, OnceCurrentVersionExpired, OnceNewDefaultVersionAvailable
  }
}

resource oaiDalle3Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: cognitiveService
  name: 'oai-dall-e-3'
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'dall-e-3'
      version: '3.0'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable' //NoAutoUpgrade, OnceCurrentVersionExpired, OnceNewDefaultVersionAvailable
  }
}

resource oaiGpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: cognitiveService
  name: 'oai-gpt-4-1106-Preview'
  sku: {
    name: 'Standard'
    capacity: 70 // The deployment will be created with a 10K TPM limit
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '1106-Preview'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable' //NoAutoUpgrade, OnceCurrentVersionExpired, OnceNewDefaultVersionAvailable
  }
}
