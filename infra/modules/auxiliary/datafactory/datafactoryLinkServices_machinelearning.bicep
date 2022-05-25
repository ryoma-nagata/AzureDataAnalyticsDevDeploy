param datafactoryId string 
param machinelearningId string 
param mlStorageId string
param env string

var mlStorageName  =  last(split(mlStorageId,'/'))
var mlWorkspaceName =  last(split(machinelearningId,'/'))

var mlStorageNameCleaned = replace(replace(mlStorageName,'mlst${env}','mlstenv'),'-','_')
var mlWorkspaceNameCleaned = replace(replace(mlWorkspaceName,'-${env}','_env'),'-','_')


resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: last(split(datafactoryId,'/'))
}

resource linkedServicesAzureMLBlob 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: mlStorageNameCleaned
  properties: {
    annotations: []
    type: 'AzureBlobStorage'
    typeProperties: {
      accountKind:'StorageV2'
      serviceEndpoint:'https://${mlStorageName}.blob.${environment().suffixes.storage}'
    }
  }
}

resource linkedServicesAzureMLService 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: datafactory
  name: mlWorkspaceNameCleaned
  properties: {
    annotations: []
    type: 'AzureMLService'
    typeProperties: {
      subscriptionId: subscription().subscriptionId
      resourceGroupName: resourceGroup().name
      mlWorkspaceName: mlWorkspaceName
      tenant: subscription().tenantId
      authentication: 'MSI'
    }
  }
}
