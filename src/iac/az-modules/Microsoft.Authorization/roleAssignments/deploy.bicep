targetScope = 'resourceGroup'

// List of principal types that can be assigned a role
// https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep#roleassignmentproperties
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string
param principalId string

@allowed([
  'Cognitive Services OpenAI User'
  'Cognitive Services OpenAI Contributor'
  'Cognitive Services Contributor'
  'Cognitive Services Usages Reader'
])
param roleDefinitions array

// It is not possible to get the role definition id from the name, so we have to hardcode it
// The command to get the role definition id is:
// az role definition list --name "Cognitive Services OpenAI Contributor" --query "[].name" -o tsv
var roleIds = {
  'Cognitive Services OpenAI Contributor': resourceId('Microsoft.Authorization/roleAssignments', 'a001fd3d-188f-4b5d-821b-7da978bf7442')
  'Cognitive Services OpenAI User': resourceId('Microsoft.Authorization/roleAssignments', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  'Cognitive Services Contributor': resourceId('Microsoft.Authorization/roleAssignments', '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68')
  'Cognitive Services Usages Reader': resourceId('Microsoft.Authorization/roleAssignments', 'bba48692-92b0-4667-a9ad-c31c7b334ac2')
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for roleDefinition in roleDefinitions: {
  name: guid(resourceGroup().id, principalId, roleDefinition)
  properties: {
    roleDefinitionId: roleIds[roleDefinition]
    principalId: principalId
    principalType: principalType
  }
}]
