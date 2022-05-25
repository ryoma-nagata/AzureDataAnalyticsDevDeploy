targetScope = 'resourceGroup'

// Parameters
param tags object
param datalakeFileSystemIds array = []
param machineLearningId string
// Variables

resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2022-01-01-preview' existing = {
  name: last(split(machineLearningId,'/'))
}

resource machineLearningDatastores 'Microsoft.MachineLearningServices/workspaces/datastores@2021-03-01-preview' = [for (datalakeFileSystemId, i) in datalakeFileSystemIds : if(length(split(datalakeFileSystemId.storageFileSystemId, '/')) == 13) {
  parent: machineLearning
  name: '${length(datalakeFileSystemIds) <= 0 ? 'undefined${i}' : split(replace(datalakeFileSystemId.storageFileSystemId,'-','_'), '/')[8]}${length(datalakeFileSystemIds) <= 0 ? 'undefined${i}' : last(split(replace(datalakeFileSystemId.storageFileSystemId,'-','_'), '/'))}'
  properties: {
    tags: tags
    contents: {
      contentsType: 'AzureDataLakeGen2'
      accountName: split(datalakeFileSystemId.storageFileSystemId, '/')[8]
      containerName: last(split(datalakeFileSystemId.storageFileSystemId, '/'))
      credentials: {
        credentialsType: 'None'
        secrets: {
          secretsType: 'None'
        }
      }
      endpoint: environment().suffixes.storage
      protocol: 'https'
    }
    description: 'Data Lake Gen2 - ${split(datalakeFileSystemId.storageFileSystemId, '/')[8]}'
    isDefault: false
  }
}]
