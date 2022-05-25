targetScope = 'resourceGroup'

param machinelearningId string
param mlStorageId string
param datafacoryPrincipalId string
param synapsePrincipalId string

var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'


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

resource mlstorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(mlStorageId,'/'))
}

resource datafactoryTomlstorageBlobContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(datafacoryPrincipalId))  {
  name: guid(datafacoryPrincipalId,mlStorageId,storageBlobDataContributorRoleId,'datafactoryTomlstorageBlobContributor')
  scope:mlstorage
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}
resource synapseTomlstorageBlobContributor 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(synapsePrincipalId))  {
  name: guid(synapsePrincipalId,mlStorageId,storageBlobDataContributorRoleId,'synapseTomlstorageBlobContributor')
  scope:mlstorage
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}
