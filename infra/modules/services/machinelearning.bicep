param location string
param tags object

param WorkspaceName string 
param keyVaultId string

param amlStorageName string
param storageIPWhiteLists array
param mlcomputeSubnetId string
param databricksSubnetId string

var resourceAccessRules = [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.MachineLearningServices/workspaces/*'
  }
] 

param applicationinsightName string 

param containerRegistryName string



module amlStorage 'storage.bicep' = {
  name: amlStorageName
  params: {
    tags:tags
    fileSystemNames: []
    isHnsEnabled: false
    location: location
    storageIPWhiteLists: storageIPWhiteLists
    storageName: amlStorageName
    storageSKU: 'Standard_RAGRS'
    virtualNetworkRules: [
      {
        id: mlcomputeSubnetId
        action: 'Allow'
      }
      {
        id: databricksSubnetId
        action: 'Allow'
      }
    ]
    resourceAccessRules: resourceAccessRules
  }
}
module amlApplicationInsight 'applicationinsight.bicep' = {
  name: applicationinsightName
  params: {
    tags:tags
    applicationinsightName: applicationinsightName
    location: location
  }
}

module amlContainerRegistry 'containerregistry.bicep' = {
  name: containerRegistryName
  params: {
    tags:tags
    containerRegistryName: containerRegistryName
    location: location
  }
}

resource machinelearning 'Microsoft.MachineLearningServices/workspaces@2022-01-01-preview' = {
  name: WorkspaceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: WorkspaceName
    keyVault: keyVaultId
    applicationInsights: amlApplicationInsight.outputs.applicationinsightId
    containerRegistry: amlContainerRegistry.outputs.containerRegistryId
    storageAccount: amlStorage.outputs.storageId
  }
}

output machinelearningWorkspaceId string = machinelearning.id
output containerRegistryId string = amlContainerRegistry.outputs.containerRegistryId
output mlstorageId string = amlStorage.outputs.storageId
output machinelearningPrincipalId string = machinelearning.identity.principalId
