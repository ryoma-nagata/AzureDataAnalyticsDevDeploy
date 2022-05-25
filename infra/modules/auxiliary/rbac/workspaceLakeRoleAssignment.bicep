targetScope = 'resourceGroup'

param synapsePrincipalId string
param workspaceLakeId string
param workspaceLakeFilesystemId string

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource workspaceLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name:  last(split(workspaceLakeId,'/'))
}

resource workspaceLakeblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
  parent:workspaceLake
  name:  'default'
}


resource workspaceLakeblobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' existing = {
  parent:workspaceLakeblob
  name: last(split(workspaceLakeFilesystemId,'/'))
}

resource synapseToworkspaceLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  = if (!empty(synapsePrincipalId)) {
  name: guid(synapsePrincipalId,workspaceLakeFilesystemId,storageBlobDataContributorRoleId,'synapseToworkspaceLake')
  scope: workspaceLakeblob
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

