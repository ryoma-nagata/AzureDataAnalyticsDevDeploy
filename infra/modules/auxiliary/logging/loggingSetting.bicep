param loggingStorageId string
var loggingStorageName = last(split(loggingStorageId,'/'))
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

// databricks
resource databricks 'Microsoft.Databricks/workspaces@2021-04-01-preview' existing = {
  name: last(split(databricksId,'/'))
}
resource databricksworkspaceallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:databricks
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

// datafactory
resource datafactory 'Microsoft.DataFactory/factories@2018-06-01'existing  = if (!empty(datafactoryId )){
  name: last(split(datafactoryId,'/'))
}
resource datafactoryallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(datafactoryId )){
  scope:datafactory
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
// synapseStorage
resource synapseStorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = if (!empty(synapseStorageId )){
  name: last(split(synapseStorageId,'/'))
}

resource synapseStorageblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' =if (!empty(synapseStorageId )){
  parent:synapseStorage
  name: 'default'
}
resource synapseStoragebloballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(synapseStorageId )){
  scope:synapseStorageblob
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
// synapse
resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' existing = if (!empty(synapseId )){
  name:  last(split(synapseId,'/'))
}

resource synapseVulnerabilityAssessments 'Microsoft.Synapse/workspaces/vulnerabilityAssessments@2021-06-01' = if (!empty(synapseId )){
  parent: synapse
  name: 'default' 
  properties: {
    storageContainerPath: vulnerbilityContainerPath
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: false
    }
  }
}
// sqlpool
resource sqlpoolAuditingSettings 'Microsoft.Synapse/workspaces/auditingSettings@2021-06-01' = if (!empty(synapseId )){
  name:  'default'
  parent:synapse
  properties:{
    state:  'Enabled'
    auditActionsAndGroups:[
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
     ]
     storageAccountSubscriptionId:subscription().subscriptionId
     storageEndpoint:'https://${loggingStorageName}.blob.${environment().suffixes.storage}/'
     isAzureMonitorTargetEnabled:true
  }
}
//sparkpool
resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' existing = if (!empty(sparkpoolId )){
  parent:synapse
  name: last(split(sparkpoolId,'/'))
}
resource sparkpoolallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(sparkpoolId )){
  scope:sparkpool
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
// machinelearning
resource machinelearning 'Microsoft.MachineLearningServices/workspaces@2022-01-01-preview' existing =if (!empty(machinelearningId )){
  name: last(split(machinelearningId,'/'))
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = if(!empty(keyvaultId )){
  name: last(split(keyvaultId,'/'))
}
resource keyvaultAudit 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(keyvaultId )){
  name: 'allLogs'
  scope: keyvault
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

resource mlstorage 'Microsoft.Storage/storageAccounts@2021-09-01' existing =  if(!empty(mlStorageId )){
  name: last(split(mlStorageId,'/'))
}
resource mlstorageblob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' =if(!empty(mlStorageId )){
  parent:mlstorage
  name: 'default'
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
// sql

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = if(!empty(sqlServerId )){
  name: last(split(sqlServerId,'/'))
}
resource sqldb 'Microsoft.Sql/servers/databases@2021-11-01-preview' existing =  if(!empty(sqldatabaseId )){
  name: last(split(sqldatabaseId,'/'))
}
resource sqldballLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(sqldatabaseId )){
  scope:sqldb
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

resource sqlAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2021-11-01-preview' = if(!empty(sqlServerId )){
  parent: sqlServer
  name: 'default'
  properties: {
    auditActionsAndGroups:[
      'BATCH_COMPLETED_GROUP'
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
     ]
    state: 'Enabled'
    storageAccountSubscriptionId:subscription().subscriptionId
    storageEndpoint: 'https://${loggingStorageName}.blob.${environment().suffixes.storage}/'
    isManagedIdentityInUse:true
  }
}


resource sqlVulnerabilityAssessments 'Microsoft.Sql/servers/vulnerabilityAssessments@2018-06-01-preview' = if(!empty(sqlServerId )){
  parent: sqlServer
  name: 'default' 
  properties: {
    storageContainerPath: vulnerbilityContainerPath
    recurringScans: {
      isEnabled: true
      emailSubscriptionAdmins: false
    }
  }
}


