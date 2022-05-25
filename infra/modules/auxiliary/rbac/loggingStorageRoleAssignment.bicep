targetScope = 'resourceGroup'

param loggingStorageId string

param synapsePrincipalId string
param sqlserverPrincipalId string

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource loggingStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(loggingStorageId,'/'))
}

resource sqlTologgingStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(sqlserverPrincipalId)) {
  name: guid(sqlserverPrincipalId,loggingStorageId,storageBlobDataContributorRoleId,'sqlTologgingStorage')
  scope: loggingStorage
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: sqlserverPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource synapseTologgingStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  = if (!empty(synapsePrincipalId)) {
  name: guid(synapsePrincipalId,loggingStorageId,storageBlobDataContributorRoleId,'synapseTologgingStorage')
  scope: loggingStorage
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}
