targetScope = 'resourceGroup'

param landingRawStorageId string
param enrichCurateStorageId string

param datafacoryPrincipalId string
param synapsePrincipalId string
param machinelearningPrincipalId string
param workspaceLakeId string
// param workspaceLakeFilesystemId string

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource landingRawLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(landingRawStorageId,'/'))
}

resource datafactoryTolandingRawLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(datafacoryPrincipalId)) {
  name: guid(datafacoryPrincipalId,landingRawStorageId,storageBlobDataContributorRoleId,'datafactoryTolandingRawLake')
  scope: landingRawLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource synapseTolandingRawLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  = if (!empty(synapsePrincipalId)) {
  name: guid(synapsePrincipalId,landingRawStorageId,storageBlobDataContributorRoleId,'synapseTolandingRawLake')
  scope: landingRawLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource enrichCurateLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(enrichCurateStorageId,'/'))
}

resource datafactoryToenrichCurateLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(datafacoryPrincipalId))  {
  name: guid(datafacoryPrincipalId,enrichCurateStorageId,storageBlobDataContributorRoleId,'datafactoryToenrichCurateLake')
  scope: enrichCurateLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource synapseToenrichCurateLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(synapsePrincipalId))  {
  name: guid(synapsePrincipalId,enrichCurateStorageId,storageBlobDataContributorRoleId,'synapseToenrichCurateLake')
  scope: enrichCurateLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}


resource machinelearningToenrichCurateLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(machinelearningPrincipalId)) {
  name: guid(machinelearningPrincipalId,enrichCurateStorageId,storageBlobDataContributorRoleId,'machinelearningToenrichCurateLake')
  scope: enrichCurateLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: machinelearningPrincipalId
    principalType: 'ServicePrincipal'
  }
}


resource workspaceLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name:  last(split(workspaceLakeId,'/'))
}

// resource workspaceLakeblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
//   parent:workspaceLake
//   name:  'default'
// }

// resource workspaceLakeblobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' existing = {
//   parent:workspaceLakeblob
//   name: last(split(workspaceLakeFilesystemId,'/'))
// }

resource synapseToworkspaceLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  = if (!empty(synapsePrincipalId)) {
  name: guid(synapsePrincipalId,workspaceLakeId,storageBlobDataContributorRoleId,'synapseToworkspaceLake')
  scope: workspaceLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource datafactoryToWorkLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(datafacoryPrincipalId))  {
  name: guid(datafacoryPrincipalId,workspaceLakeId,storageBlobDataContributorRoleId,'datafactoryToWorkLake')
  scope: workspaceLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: datafacoryPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource machinelearningToWorkLake 'Microsoft.Authorization/roleAssignments@2020-04-01-preview'  =if (!empty(machinelearningPrincipalId)) {
  name: guid(machinelearningPrincipalId,workspaceLakeId,storageBlobDataContributorRoleId,'machinelearningToWorkLake')
  scope: workspaceLake
  properties: {
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: machinelearningPrincipalId
    principalType: 'ServicePrincipal'
  }
}
