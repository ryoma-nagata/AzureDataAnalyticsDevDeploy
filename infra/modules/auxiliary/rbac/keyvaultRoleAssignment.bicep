targetScope = 'resourceGroup'

param keyvaultId string
param datafacoryPrincipalId string
param synapsePrincipalId string
param databricksAppObjectId string

var secretUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var secretOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: last(split(keyvaultId,'/'))
}

resource datafactoryToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(datafacoryPrincipalId))  {
  name: guid(datafacoryPrincipalId,keyvaultId,secretUserRoleId,'datafactoryToDatabricksContributor')
  scope:keyvault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', secretUserRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}
resource synapseToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(synapsePrincipalId))  {
  name: guid(synapsePrincipalId,keyvaultId,secretUserRoleId,'synapseToDatabricksContributor')
  scope:keyvault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', secretUserRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource databricksAppToDatabricksContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(databricksAppObjectId))  {
  name: guid(databricksAppObjectId,keyvaultId,secretOfficerRoleId,'databricksAppToDatabricksContributor')
  scope:keyvault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', secretOfficerRoleId)
    principalId: databricksAppObjectId
    principalType: 'ServicePrincipal'
  }
}
