@description('That name is the name of the service')
param cognitiveServiceName string

@description('Location for all resources.')
@allowed([
  'East US'
])
param location string

@allowed([
  'S0'
])
param sku string

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServiceName
  location: location
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: cognitiveServiceName
  }
}
