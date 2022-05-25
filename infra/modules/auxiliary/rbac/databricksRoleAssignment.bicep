targetScope = 'resourceGroup'

param databricksWorkspaceId string
param datafacoryPrincipalId string
param synapsePrincipalId string

var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'


resource databricks 'Microsoft.Databricks/workspaces@2021-04-01-preview' existing = {
  name: last(split(databricksWorkspaceId,'/'))
}

resource datafactoryToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(datafacoryPrincipalId )) {
  name: guid(datafacoryPrincipalId,databricksWorkspaceId,contributorRoleId,'datafactoryToDatabricksContributor')
  scope:databricks
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource synapseToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (!empty(synapsePrincipalId )) {
  name: guid(synapsePrincipalId,databricksWorkspaceId,contributorRoleId,'synapseToDatabricksContributor')
  scope:databricks
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

