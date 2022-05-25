param loggingStorageId string
param loganalyticsId string

param machinelearningId string
param mlStorageId string
param mlAcrId string


// machinelearning
resource machinelearning 'Microsoft.MachineLearningServices/workspaces@2022-01-01-preview' existing =if (!empty(machinelearningId )){
  name: last(split(machinelearningId,'/'))
}

resource mlstorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing =  if(!empty(mlStorageId )){
  name: last(split(mlStorageId,'/'))
}
resource mlstorageblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' =if(!empty(mlStorageId )){
  parent:mlstorage
  name: 'default'
}

resource mlContainerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = if (!empty(mlAcrId )){
  name:  last(split(mlAcrId,'/'))
}

resource mlstoragebloballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(mlStorageId )){
  scope:mlstorageblob
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}

resource mlallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(machinelearningId )){
  scope:machinelearning
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    workspaceId:loganalyticsId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}

resource mlContainerRegistryallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(mlAcrId )){
  scope:mlContainerRegistry
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    workspaceId:loganalyticsId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}



