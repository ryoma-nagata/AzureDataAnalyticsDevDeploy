targetScope = 'resourceGroup'

param machinelearningId string
param datafacoryPrincipalId string
param synapsePrincipalId string

var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'


resource machinelearning 'Microsoft.MachineLearningServices/workspaces@2022-01-01-preview' existing = {
  name: last(split(machinelearningId,'/'))
}

resource datafactoryToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(datafacoryPrincipalId))  {
  name: guid(datafacoryPrincipalId,machinelearningId,contributorRoleId,'datafactoryToDatabricksContributor')
  scope:machinelearning
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}
resource synapseToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(synapsePrincipalId))  {
  name: guid(synapsePrincipalId,machinelearningId,contributorRoleId,'synapseToDatabricksContributor')
  scope:machinelearning
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

