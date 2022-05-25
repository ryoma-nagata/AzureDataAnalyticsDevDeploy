param loggingStorageId string
param loganalyticsId string

param uploadStorageId string 
param landingRawStorageId  string
param enrichCurateStorageId string

param databricksId string
param datafactoryId string
param synapseStorageId string
param synapseId string
param sparkpoolId string 

param keyvaultId string
param machinelearningId string
param mlStorageId string
param mlAcrId string

param sqlServerId string
param sqldatabaseId string

param vulnerbilityContainerPath string



//upload storage
resource uploadStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(uploadStorageId,'/'))
}

resource uploadStorageblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' ={
  parent:uploadStorage
  name: 'default'
}
resource uploadStoragebloballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:uploadStorageblob
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

// landingraw
resource landingRawLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(landingRawStorageId,'/'))
}
resource landingRawLakeblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' ={
  parent:landingRawLake
  name: 'default'
}
resource landingRawLakebloballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:landingRawLakeblob
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


// enrichcurate
resource enrichCurateLake 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(enrichCurateStorageId,'/'))
}
resource enrichCurateLakeBlob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' ={
  parent:enrichCurateLake
  name: 'default'
}
resource enrichCurateLakeBloballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:enrichCurateLakeBlob
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


resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing ={
  name: last(split(keyvaultId,'/'))
}
resource keyvaultAudit 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' ={
  name: 'allLogs'
  scope: keyvault
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


module  loggingSetting_synapse 'loggingSetting_synapse.bicep'  = if (!empty(synapseStorageId )){
  name: 'loggingSetting_synapse'
  params:{
    synapseStorageId: synapseStorageId
    vulnerbilityContainerPath: vulnerbilityContainerPath
    loganalyticsId: loganalyticsId
    sparkpoolId: sparkpoolId
    loggingStorageId: loggingStorageId
    synapseId: synapseId
  }
}

module  loggingSetting_sql 'loggingSetting_sql.bicep'  = if (!empty(sqlServerId )){
  name: 'loggingSetting_sql'
  params:{
    sqlServerId: sqlServerId
    vulnerbilityContainerPath: vulnerbilityContainerPath
    loganalyticsId: loganalyticsId
    loggingStorageId: loggingStorageId
    sqldatabaseId:sqldatabaseId
  }
}

module  loggingSetting_machinelearning 'loggingSetting_machinelearning.bicep'  = if (!empty(machinelearningId )){
  name: 'loggingSetting_machinelearning'
  params:{
    loganalyticsId: loganalyticsId
    loggingStorageId: loggingStorageId
    machinelearningId:machinelearningId
    mlStorageId:mlStorageId
    mlAcrId:mlAcrId
  }
}

module  loggingSetting_datafactory 'loggingSetting_datafactory.bicep'  = if (!empty(datafactoryId )){
  name: 'loggingSetting_datafactory'
  params:{
    loganalyticsId: loganalyticsId
    loggingStorageId: loggingStorageId
    datafactoryId:datafactoryId
  }
}

module  loggingSetting_databricks 'loggingSetting_databricks.bicep'  = if (!empty(databricksId )){
  name: 'loggingSetting_databricks'
  params:{
    loganalyticsId: loganalyticsId
    loggingStorageId: loggingStorageId
    databricksId:databricksId
  }
}
