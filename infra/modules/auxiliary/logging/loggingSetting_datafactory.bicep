param loggingStorageId string
param loganalyticsId string
param datafactoryId string

// datafactory
resource datafactory 'Microsoft.DataFactory/factories@2018-06-01'existing  = if (!empty(datafactoryId )){
  name: last(split(datafactoryId,'/'))
}
resource datafactoryallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(datafactoryId )){
  scope:datafactory
  name: 'allLogs'
  properties:{
    storageAccountId:loggingStorageId
    logAnalyticsDestinationType:'Dedicated'
    workspaceId:loganalyticsId
    logs:[
      {
        categoryGroup:'allLogs'
        enabled: true
      }
    ]
  }
}


