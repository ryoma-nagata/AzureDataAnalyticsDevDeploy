targetScope = 'resourceGroup'

param uploadStorageId string

param synapsePrincipalId string
param datafacoryPrincipalId string

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource uploadStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(uploadStorageId,'/'))
}


resource synapseTologgingStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  = if (!empty(synapsePrincipalId)) {
  name: guid(synapsePrincipalId,uploadStorageId,storageBlobDataContributorRoleId,'synapseTologgingStorage')
  scope: uploadStorage
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}
resource datafactoryTolandingRawLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(datafacoryPrincipalId)) {
  name: guid(datafacoryPrincipalId,uploadStorageId,storageBlobDataContributorRoleId,'datafactoryTolandingRawLake')
  scope: uploadStorage
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}
