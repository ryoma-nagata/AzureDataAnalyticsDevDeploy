param loggingStorageId string
param loganalyticsId string
param cognitiveservicesId string



//  cognitve
resource cognitiveservices 'Microsoft.CognitiveServices/accounts@2022-03-01' existing = {
  name: last(split(cognitiveservicesId,'/'))
}

resource cognitiveservicesallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope:cognitiveservices
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
